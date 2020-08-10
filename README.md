# proxysql-freno
A playground for MySQL + ProxySQL + pt-heartbeat + Freno

## Testing

### Start environment
_Note: wait a few minutes for errors to subside_
```
$ make
```

### View logs
```
$ make logs
```

### Use ProxySQL shell
```
$ ./mysql-shell.sh -h proxysql -P 6032
...

mysql> select * from stats.stats_mysql_connection_pool where hostgroup=20;
+-----------+----------+----------+--------+----------+----------+--------+---------+-------------+---------+-------------------+-----------------+-----------------+------------+
| hostgroup | srv_host | srv_port | status | ConnUsed | ConnFree | ConnOK | ConnERR | MaxConnUsed | Queries | Queries_GTID_sync | Bytes_data_sent | Bytes_data_recv | Latency_us |
+-----------+----------+----------+--------+----------+----------+--------+---------+-------------+---------+-------------------+-----------------+-----------------+------------+
| 20        | replica1 | 3306     | ONLINE | 0        | 0        | 0      | 0       | 0           | 0       | 0                 | 0               | 0               | 531        |
| 20        | replica2 | 3306     | ONLINE | 0        | 0        | 0      | 0       | 0           | 0       | 0                 | 0               | 0               | 487        |
| 20        | replica3 | 3306     | ONLINE | 0        | 0        | 0      | 0       | 0           | 0       | 0                 | 0               | 0               | 619        |
+-----------+----------+----------+--------+----------+----------+--------+---------+-------------+---------+-------------------+-----------------+-----------------+------------+
3 rows in set (0.01 sec)
```

### Simulate replication lag
```
$ ./mysql-shell.sh -h replica3
...

mysql> stop slave; change master to master_delay=90; start slave;
Query OK, 0 rows affected (0.01 sec)

Query OK, 0 rows affected (0.02 sec)

Query OK, 0 rows affected (0.00 sec)
```

### Simulate node failure
To pause:
```
$ docker-compose pause replica1
```

To unpause:
```
$ docker-compose unpause replica1
```

### Do Freno check
```
$ ./freno-check.sh
{
  "StatusCode": 200,
  "Value": 0.1128,
  "Threshold": 1,
  "Message": ""
}
```
