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



CREATE DATABASE IF NOT EXISTS test;
USE test;

CREATE TABLE IF NOT EXISTS test (
    id INT AUTO_INCREMENT,
    msg VARCHAR(128),
    PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE USER IF NOT EXISTS 'test_rw'@'%';
SET PASSWORD FOR 'test_rw'@'%' = PASSWORD('123456');
GRANT SELECT, INSERT, UPDATE, DELETE ON test.* TO 'test_rw'@'%';

CREATE USER IF NOT EXISTS 'test_ro'@'%';
SET PASSWORD FOR 'test_ro'@'%' = PASSWORD('123456');
GRANT SELECT ON test.* TO 'test_ro'@'%';
