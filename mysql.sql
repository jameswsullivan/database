mysql -h host -u username -p

-- Connect to MySQL server with auto-rehash disabled to save startup time.
mysql --disable-auto-rehash --local-infile=1 -u root -p

SHOW DATABASES;

SHOW TABLES;

CREATE DATABASE <database-name>;

DROP DATABASE <database-name>;

CREATE USER 'username'@'host' IDENTIFIED BY 'password';

GRANT ALL PRIVILEGES ON <database-name>.* TO 'username'@'host' WITH GRANT OPTION;

FLUSH PRIVILEGES;

REVOKE ALL PRIVILEGES ON <database-name>.* FROM 'username'@'host';

SHOW GRANTS FOR 'username'@'host';

SET PASSWORD FOR 'username'@'host' = 'password';

CREATE TABLE <table-name> (
    <col-name-01> INT,
    <col-name-02> DECIMAL(10, 2),
    <col-name-03> FLOAT,
    <col-name-04> CHAR(10),
    <col-name-05> VARCHAR(255),
    <col-name-06> TEXT,
    <col-name-07> DATE,
    <col-name-08> TIME,
    <col-name-09> DATETIME,
    <col-name-10> TIMESTAMP,
    <col-name-11> BOOLEAN,
    <col-name-12> BLOB,
    <col-name-13> ENUM('value1', 'value2', 'value3')
);

INSERT INTO <table-name> (col1, col2, ...) VALUES (val1, val2, ...);

SELECT * FROM <table-name> WHERE condition;

UPDATE <table-name> SET col1 = val1, col2 = val2 WHERE condition;

DELETE FROM <table-name> WHERE condition;

SHOW DATABASES;

USE <database-name>;

SHOW TABLES;

DESCRIBE <database-name>;

EXIT;

-- Find all users and hosts:
SELECT user, host FROM mysql.user;

SHOW GRANTS FOR 'username'@'host';











