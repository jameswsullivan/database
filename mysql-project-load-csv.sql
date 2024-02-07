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