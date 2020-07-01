#!/bin/bash

run_sql() {
  local host="${1}"
  local sql_path="${2}"

  if [ ! -r "$sql_path" ]; then
    echo "ERROR: SQL script not found: '${sql_path}'"
    exit 1
  fi

  while true; do
    echo "Running SQL script on ${host}: '${sql_path}'"
    mysql -uroot -p123456 -h${host} <${sql_path}
    [ $? -lt 1 ] && break
    echo "WARNING: retrying SQL script on ${host}: '${sql_path}' in 3 seconds"
    sleep 3 
  done
}

run_sql master /sql/setup-heartbeat.sql
run_sql replica1 /sql/setup-replication.sql
run_sql replica2 /sql/setup-replication.sql
