#!/bin/bash

(
	while true; do
		if [ "$(mysql -uroot -p123456 -NBe 'select @@global_read_only' 2>/dev/null)" == "1" ]; then
  			/usr/bin/proxysql_binlog_reader -h 127.0.0.1 -u root -p 123456 -P 3306 -l 33060 -L /tmp/proxysql_binlog_reader.log
		fi
		sleep 5
	done
) & disown $!
