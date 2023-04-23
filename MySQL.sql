/*
Project: Vireo and Oaktrust.
This project involves removing duplicates from two separate datasets and checking if any records are in one dateset but not the other and identify these missing records.
The datasets are named as "vireo" and "oaktrust", respectively.
*/

-- Create tables.
CREATE TABLE vireo (id INT NOT NULL AUTO_INCREMENT, lastname VARCHAR(128), depositid VARCHAR(512), documenttitle VARCHAR(512), PRIMARY KEY (id)) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
LOAD DATA LOCAL INFILE './home/vireoimport.csv' INTO TABLE vireo FIELDS TERMINATED BY ',' ENCLOSED BY '"' (documenttitle,depositid,lastname);

CREATE TABLE oaktrust (id INT NOT NULL AUTO_INCREMENT, name VARCHAR(128), uuid VARCHAR(512), documenttitle VARCHAR(512), depositid VARCHAR(512), PRIMARY KEY (id)) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
LOAD DATA LOCAL INFILE './home/oaktrustimport.csv' INTO TABLE oaktrust FIELDS TERMINATED BY ',' ENCLOSED BY '"' (uuid,documenttitle,name,depositid);

-- Filter duplicate titles, test run.
SELECT vireo1.documenttitle, vireo1.lastname, SUBSTRING(vireo1.depositid, 23, LENGTH(vireo1.depositid))
FROM vireo vireo1
RIGHT JOIN (
    SELECT vireo2.documenttitle, COUNT(documenttitle) AS duplicates
    FROM vireo vireo2
    GROUP BY vireo2.documenttitle
    HAVING duplicates > 1
) vireoduplicates ON vireo1.documenttitle=vireoduplicates.documenttitle
ORDER BY vireo1.documenttitle ASC
LIMIT 10;

-- Filter duplicate records in vireo and export into .csv
SELECT vireo1.documenttitle, vireo1.lastname, SUBSTRING(vireo1.depositid, 23, LENGTH(vireo1.depositid))
FROM vireo vireo1
RIGHT JOIN (
    SELECT vireo2.documenttitle, COUNT(documenttitle) AS duplicates
    FROM vireo vireo2
    GROUP BY vireo2.documenttitle
    HAVING duplicates > 1
) vireoduplicates ON vireo1.documenttitle=vireoduplicates.documenttitle
ORDER BY vireo1.documenttitle ASC
INTO OUTFILE '/var/lib/mysql-files/vireoduplicates.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

-- Filter duplicate records in oaktrust, test run.
SELECT oaktrust1.documenttitle, oaktrust1.name, oaktrust1.depositid, oaktrust1.uuid
FROM  oaktrust oaktrust1
RIGHT JOIN (
    SELECT oaktrust2.documenttitle, COUNT(documenttitle) AS duplicates
    FROM oaktrust oaktrust2
    GROUP BY oaktrust2.documenttitle
    HAVING duplicates > 1
) oaktrustduplicates ON oaktrust1.documenttitle=oaktrustduplicates.documenttitle
ORDER BY oaktrust1.documenttitle ASC
LIMIT 10;

-- Filter duplicate records in oaktrust and export into .csv
SELECT oaktrust1.documenttitle, oaktrust1.name, oaktrust1.depositid, oaktrust1.uuid
FROM  oaktrust oaktrust1
RIGHT JOIN (
    SELECT oaktrust2.documenttitle, COUNT(documenttitle) AS duplicates
    FROM oaktrust oaktrust2
    GROUP BY oaktrust2.documenttitle
    HAVING duplicates > 1
) oaktrustduplicates ON oaktrust1.documenttitle=oaktrustduplicates.documenttitle
ORDER BY oaktrust1.documenttitle ASC
INTO OUTFILE '/var/lib/mysql-files/oaktrustduplicates.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

-- Check for missing records between each other.
SELECT vireo.documenttitle, vireo.lastname, SUBSTRING(vireo.depositid, 23, LENGTH(vireo.depositid))
FROM vireo
WHERE vireo.documenttitle NOT IN (
    SELECT oaktrust.documenttitle
    FROM oaktrust
)
ORDER BY vireo.documenttitle ASC
LIMIT 10;

SELECT vireo.documenttitle, vireo.lastname, SUBSTRING(vireo.depositid, 23, LENGTH(vireo.depositid))
FROM vireo
WHERE vireo.documenttitle NOT IN (
    SELECT oaktrust.documenttitle
    FROM oaktrust
)
ORDER BY vireo.documenttitle ASC
INTO OUTFILE '/var/lib/mysql-files/invireonotinoaktrust.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';

SELECT oaktrust.documenttitle, oaktrust.name, oaktrust.depositid, oaktrust.uuid
FROM oaktrust
WHERE oaktrust.documenttitle NOT IN (
    SELECT vireo.documenttitle
    FROM vireo
)
ORDER BY oaktrust.documenttitle ASC
LIMIT 10;


SELECT oaktrust.documenttitle, oaktrust.name, oaktrust.depositid, oaktrust.uuid
FROM oaktrust
WHERE oaktrust.documenttitle NOT IN (
    SELECT vireo.documenttitle
    FROM vireo
)
ORDER BY oaktrust.documenttitle ASC
INTO OUTFILE '/var/lib/mysql-files/inoaktrustnotinvireo.csv'
FIELDS ENCLOSED BY '"'
TERMINATED BY ','
ESCAPED BY '"'
LINES TERMINATED BY '\r\n';



/* Load csv datasets into MySQL database. */

SET GLOBAL local_infile=1;

/* Create the customer database and the customer_data table */
CREATE DATABASE customer;
USE customer;

CREATE TABLE customer_data (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(512),
    dob DATE,
    sex VARCHAR(64),
    phone_number VARCHAR(256),
    address VARCHAR(1024),
    id_number VARCHAR(256),
    control_number VARCHAR(256),
    addr_type VARCHAR(256),
    registration_place VARCHAR(256),
    data_entry_time DATETIME,
    PRIMARY KEY (id))
CHARACTER SET utf8mb4
COLLATE utf8mb4_0900_ai_ci;

/* Load csv files. */
LOAD DATA LOCAL INFILE 'customer_data.csv'
INTO TABLE customer_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(registration_place,data_entry_time,addr_type,control_number,dob,sex,id_number,name,phone_number,address);

/* Connect to MySQL server with auto-rehash disabled to save startup time. */
mysql --disable-auto-rehash --local-infile=1 -u root -p