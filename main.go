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
	Id  int    `db:"id"`
	Msg string `db:"msg"`
}

type App struct {
	throttled    uint32
	throttle_cnt uint32
	insert_oks   uint32
	insert_errs  uint32
	select_oks   uint32
	select_errs  uint32
	select_chan  chan int64
}

func main() {
	db, err := sqlx.Connect("mysql", "testbed_rw:rw123456@tcp(proxysql:3306)/testbed")
	if err != nil {
		log.Fatal(err)
	}
	dbRO, err := sqlx.Connect("mysql", "testbed_ro:ro123456@tcp(proxysql:3306)/testbed")
	if err != nil {
		log.Fatal(err)
	}
	log.Printf("ping rw: %v\n", db.Ping())
	log.Printf("ping ro: %v\n", dbRO.Ping())

	app := &App{
		select_chan: make(chan int64, 1024),
	}
	atomic.StoreUint32(&app.throttled, 0)

	go func(dbRO *sqlx.DB, app *App) {
		for id := range app.select_chan {
			start := time.Now()
			go func() {
				var done bool
				for !done {
					select {
					default:
						var row Row
						err = dbRO.Get(&row, fmt.Sprintf("SELECT id, msg FROM testbed.test WHERE id=%d", id))
						if err != nil {
							time.Sleep(time.Millisecond)
						} else {
							atomic.AddUint32(&app.select_oks, 1)
							//log.Printf("select: %v, duration: %v", row, time.Since(start))
							done = true
						}
					case <-time.After(500 * time.Millisecond):
						atomic.AddUint32(&app.select_errs, 1)
						log.Printf("select timed out at duration: %v", time.Since(start))
						done = true
					}
				}
			}()
		}
	}(dbRO, app)

	hc := &http.Client{}
	frenoTicker := time.NewTicker(2 * time.Second)
	insertTicker := time.NewTicker(10 * time.Millisecond)
	statusTicker := time.NewTicker(10 * time.Second)
	for {
		select {
		case <-statusTicker.C:
			log.Printf("status: insert_ok=%d, insert_err=%d, select_ok=%d, select_errs=%d, throttle_cnt=%d",
				app.insert_oks,
				app.insert_errs,
				app.select_oks,
				app.select_errs,
				app.throttle_cnt,
			)
		case <-frenoTicker.C:
			go func() {
				res, err := hc.Get("http://freno:8111/check/test/mysql/testbed")
				if err != nil {
					log.Fatal(err)
				}

				bytes, _ := ioutil.ReadAll(res.Body)
				log.Printf("freno: %s", string(bytes))
				if res.StatusCode == http.StatusOK {
					atomic.StoreUint32(&app.throttled, 0)
				} else {
					atomic.StoreUint32(&app.throttled, 1)
				}
			}()
		case <-insertTicker.C:
			go func() {
				if atomic.LoadUint32(&app.throttled) != 0 {
					atomic.AddUint32(&app.throttle_cnt, 1)
					log.Println("inserts throttled")
					return
				}
				res := db.MustExec("INSERT INTO testbed.test (msg) values('hello world!')")
				id, err := res.LastInsertId()
				if err != nil {
					atomic.AddUint32(&app.insert_errs, 1)
					log.Fatal(err)
				} else {
					atomic.AddUint32(&app.insert_oks, 1)
					app.select_chan <- id
				}
				//log.Printf("insert: %v\n", id)
			}()
		}
	}
}
