CREATE DATABASE IF NOT EXISTS freno;
USE freno;

DROP TABLE IF EXISTS service_election;
CREATE TABLE service_election (
  domain varchar(32) NOT NULL,
  share_domain varchar(32) NOT NULL,
  service_id varchar(128) NOT NULL,
  last_seen_active timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (domain),
  KEY share_domain_idx (share_domain,last_seen_active)
);

DROP TABLE IF EXISTS throttled_apps;
CREATE TABLE throttled_apps (
  app_name varchar(128) NOT NULL,
  throttled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  ratio DOUBLE,
  PRIMARY KEY (app_name)
);
