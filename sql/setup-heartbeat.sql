CREATE DATABASE IF NOT EXISTS percona;

CREATE USER IF NOT EXISTS 'heartbeat'@'%';
SET PASSWORD FOR 'heartbeat'@'%' = PASSWORD('heartbeat');
GRANT ALL on percona.* TO 'heartbeat'@'%';
