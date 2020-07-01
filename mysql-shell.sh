#!/bin/bash

host=master
port=3306
user=root
password=123456

while getopts "h:u:p:P:e:" opt; do
  case ${opt} in
    h)
      host=$OPTARG
      ;;
    u)
      user=$OPTARG
      ;;
    P)
      port=$OPTARG
      ;;
    p)
      password=$OPTARG
      ;;
    e)
      execQuery=$OPTARG
      ;;
  esac
done

docker run --rm -it --network=proxysql-testbed_default \
	--link=${host}:${host} --entrypoint=mysql mysql:5.7 -h ${host} -P ${port} -u${user} -p${password} ${extra}
