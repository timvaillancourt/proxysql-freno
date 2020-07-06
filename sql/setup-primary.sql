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



CREATE DATABASE IF NOT EXISTS testbed;
USE testbed;

CREATE TABLE IF NOT EXISTS test (
    id INT AUTO_INCREMENT,
    msg VARCHAR(128),
    PRIMARY KEY(id)
) ENGINE=InnoDB;

CREATE USER IF NOT EXISTS 'testbed_rw'@'%';
SET PASSWORD FOR 'testbed_rw'@'%' = PASSWORD('rw123456');
GRANT SELECT, INSERT, UPDATE, DELETE ON testbed.* TO 'testbed_rw'@'%';

CREATE USER IF NOT EXISTS 'testbed_ro'@'%';
SET PASSWORD FOR 'testbed_ro'@'%' = PASSWORD('ro123456');
GRANT SELECT ON testbed.* TO 'testbed_ro'@'%';
