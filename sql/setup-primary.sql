CREATE USER IF NOT EXISTS 'repl'@'%';
SET PASSWORD FOR 'repl'@'%' = PASSWORD('repl');
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';

CREATE DATABASE IF NOT EXISTS percona;
CREATE USER IF NOT EXISTS 'heartbeat'@'%';
SET PASSWORD FOR 'heartbeat'@'%' = PASSWORD('heartbeat');
GRANT REPLICATION CLIENT ON *.* TO 'heartbeat'@'%';
GRANT CREATE, SELECT, INSERT, UPDATE ON percona.* TO 'heartbeat'@'%';

CREATE USER IF NOT EXISTS 'proxysql'@'%';
SET PASSWORD FOR 'proxysql'@'%' = PASSWORD('proxysql');
GRANT REPLICATION CLIENT ON *.* TO 'proxysql'@'%';
GRANT SELECT ON percona.* TO 'proxysql'@'%';
