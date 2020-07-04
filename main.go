package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"sync/atomic"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
)

type Row struct {
	Id       int    `db:"id"`
	Msg      string `db:"msg"`
	Hostname string `db:"hostname"`
}

type App struct {
	throttled *uint32
}

func main() {
	rwDB, err := sqlx.Connect("mysql", "test_rw:123456@tcp(proxysql:3306)/test")
	if err != nil {
		log.Fatal(err)
	}

	roDB, err := sqlx.Connect("mysql", "test_ro:123456@tcp(proxysql:3306)/test")
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("ping rw: %v\n", rwDB.Ping())
	log.Printf("ping ro: %v\n", roDB.Ping())

	var insert_oks, insert_errs, select_oks, select_errs uint
	selectChan := make(chan int64, 0)
	go func(roDB *sqlx.DB, ids chan int64, select_oks, select_errs uint) {
		for id := range ids {
			time.Sleep(500 * time.Millisecond)
			var row Row
			err = roDB.Get(&row, fmt.Sprintf("SELECT id, msg, @@hostname as hostname FROM test.test WHERE id=%d", id))
			if err != nil {
				log.Printf("error SELECTing %d: %v", id, err)
				select_errs += 1
			} else {
				select_oks += 1
			}
			log.Printf("select: %v\n", row)
		}
	}(roDB, selectChan, select_oks, select_errs)

	go func(insert_oks, insert_errs, select_oks, select_errs uint) {
		statusTicker := time.NewTicker(3 * time.Second)
		select {
		case <-statusTicker.C:
			log.Printf("status: insert_ok: %d, insert_err: %d, select_ok: %d, select_errs: %d", insert_oks, insert_errs, select_oks, select_errs)
		}
	}(insert_oks, insert_errs, select_oks, select_errs)

	a := &App{throttled: nil}
	atomic.StoreUint32(a.throttled, 0)
	go func(a *App) {
		hc := &http.Client{}
		frenoTicker := time.NewTicker(time.Second)
		select {
		case <-frenoTicker.C:
			res, err := hc.Get("http://freno:8111/check/test/mysql/testbed")
			if err != nil {
				log.Fatal(err)
			}

			bytes, _ := ioutil.ReadAll(res.Body)
			log.Printf("freno: %s", string(bytes))
			if res.StatusCode == http.StatusOK {
				atomic.StoreUint32(a.throttled, 0)
			} else {
				atomic.StoreUint32(a.throttled, 1)
			}
		}
	}(a)

	insertTicker := time.NewTicker(250 * time.Millisecond)
	for {
		select {
		case <-insertTicker.C:
			if atomic.LoadUint32(a.throttled) != 0 {
				res := rwDB.MustExec("INSERT INTO test.test (msg) values('hello world!')")
				id, err := res.LastInsertId()
				if err != nil {
					insert_errs += 1
					log.Fatal(err)
				} else {
					insert_oks += 1
					selectChan <- id
				}
				log.Printf("insert: %v\n", id)
			}
		}
	}
}
