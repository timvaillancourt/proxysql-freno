#!/bin/bash

host=${1:-master}
port=${2:-3306}
user=${3:-root}
password=${4:-123456}

docker run --rm -it --network=proxysql-testbed_default \
	--link=${host}:${host} --entrypoint=mysql mysql:5.7 -h ${host} -P ${port} -u${user} -p${password}
