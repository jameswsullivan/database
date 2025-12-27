-- Common commands:
\l   -- List databases
\l+  -- List databases, extended/detailed view
\x   -- Expand/narrow table list
\du  -- Display users/roles
\dt  -- Display tables
\ds  -- List available sequences
\q   -- Quit psql
\c <database_name>   -- Connect to a database
  
-- Making database connections:
psql -U <USERNAME> -h <DATABASE_HOST> -p <PORT> -W -d <DATABASE_NAME>
pg_dump -U <USERNAME> -h <DATABASE_HOST> -p <PORT> -d <DATABASE_NAME> -f OUTPUT_FILE.sql

-- Import/export a database:
psql <DATABASE_NAME> < INPUT_FILE.sql
pg_dump <DATABASE_NAME> > OUTPUT_FILE.sql
pg_restore -d <DATABASE_NAME> <PATH_TO_DUMP_FILE, e.g. mydb.dump>
PGPASSWORD=<PASSWORD> psql -U <USERNAME> -h <DATABASE_HOST> -d <DATABASE_NAME> < INPUT_FILE.sql
  
-- Create/drop database/roles.
CREATE ROLE <ROLE_NAME> WITH LOGIN SUPERUSER PASSWORD '<PASSWORD>' CONNECTION LIMIT -1;
CREATE ROLE <ROLE_NAME> WITH LOGIN PASSWORD '<PASSWORD>' CONNECTION LIMIT -1;
CREATE DATABASE <DATABASE_NAME> WITH OWNER = <ROLE_NAME> ENCODING = 'UTF8' CONNECTION LIMIT = -1;
DROP DATABASE <DATABASE_NAME>;

-- Rename databases:
ALTER DATABASE <old_db_name> RENAME TO <new_db_name>;

-- SELECT :
-- SELECT with CONCAT :
SELECT CONCAT(<COL1>, <STRING1>, <COL2>) AS <ALIAS_1>
FROM <TABLE_NAME>;

-- TRIM and LOWER :
SELECT LOWER(TRIM(email)) AS lower_case_email
FROM users;

-- Save data to CSV file :
COPY (SELECT your_columns FROM your_table) 
TO '/path/to/your/file.csv' 
WITH CSV HEADER;

-- Create table :
CREATE TABLE <TABLE_NAME> (
    col1    integer PRIMARY KEY,
    col2    varchar(40)
);

-- Insert data :
INSERT INTO <TABLE_NAME> VALUES (1, 'something');

INSERT INTO <TABLE_NAME> (col1, col2, ...)
VALUES (val1, val2, ...);

-- Update:
UPDATE <TABLE_NAME>
SET <COLUMN_NAME> = <NEW_VALUE>
WHERE <CONDITION>;

UPDATE <TABLE_NAME>
SET <COL1> = <NEW_VALUE>, <COL2> = <NEW_VALUE>, ...

UPDATE <TABLE_NAME>
SET <COL1> = CASE
                WHEN <CONDITION1> THEN <VALUE1>
                WHEN <CONDITION2> THEN <VALUE2>
                ...
              ELSE <DEFAULT_VALUE>
            END
WHERE <CONDITION>;

-- View and alter roles and privileges:
ALTER ROLE <USERNAME> RENAME TO <NEW_USERNAME>;
ALTER USER <USERNAME> WITH PASSWORD '<PASSWORD>';
ALTER TABLE table_name OWNER TO new_owner;

GRANT ALL PRIVILEGES ON DATABASE <DATABASE_NAME> TO <USER>;
GRANT CONNECT ON DATABASE <DATABASE_NAME> TO <ROLE_NAME>;
GRANT CONNECT ON DATABASE <DATABASE_NAME> TO <USER1>, <USER2>;
GRANT USAGE ON SCHEMA public TO <USER1>, <USER2>;
GRANT SELECT ON TABLE <TABLE_NAME> TO <USER1>, <USER2>;
GRANT INSERT, UPDATE, DELETE ON TABLE <TABLE_NAME> TO <USER>;

REVOKE CONNECT ON DATABASE <DATABASE_NAME> FROM <USER1>, <USER2>;
REVOKE USAGE ON SCHEMA public FROM <USER1>, <USER2>;
REVOKE SELECT ON TABLE <TABLE_NAME> FROM <USER1>, <USER2>;
REVOKE INSERT, UPDATE, DELETE ON TABLE <TABLE_NAME> FROM <USER>;
REVOKE CONNECT ON DATABASE <DATABASE_NAME> FROM PUBLIC;

SELECT * FROM information_schema.columns WHERE table_name = '<TABLE_NAME>';

-- Reference:
-- Tc and CTC = ALL PRIVILEGES
-- c = CONNECT
-- https://www.postgresql.org/docs/current/ddl-priv.html
-- https://docs.digitalocean.com/products/databases/postgresql/how-to/modify-user-privileges/

-- Show privileges for a specific user on databases:
SELECT datname, has_database_privilege(grantee, datname, privilege_type) AS privilege
FROM pg_database
CROSS JOIN pg_roles
WHERE rolname = '<ROLE_NAME>';

-- Show privileges for a specific user on schemas:
SELECT schema_name, has_schema_privilege(grantee, schema_name, privilege_type) AS privilege
FROM information_schema.schemata
CROSS JOIN pg_roles
WHERE rolname = '<ROLE_NAME>';

-- Show privileges for a specific user on tables:
SELECT table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = '<ROLE_NAME>';

-- Show privileges for a specific user on columns:
SELECT table_schema, table_name, column_name, privilege_type
FROM information_schema.column_privileges
WHERE grantee = '<ROLE_NAME>';

-- Checking for Data in a Specific Schema:
SELECT schemaname, tablename, reltuples
FROM pg_stat_user_tables
WHERE schemaname = '<SCHEMA_NAME>';

-- Checking for Data in the Entire Database:
SELECT schemaname, tablename, reltuples
FROM pg_stat_all_tables;

-- List all schemas in a PostgreSQL database
SELECT schema_name
FROM information_schema.schemata;


-- Find and disable OIDS:
-- Find tables that have OIDS
SELECT
    nspname,
    relname,
    relhasoids
FROM pg_class
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE nspname = 'public' AND relhasoids = true;

--  Find tables that have OIDS but only show table names:
SELECT relname
FROM pg_class
JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
WHERE nspname = 'public' AND relhasoids = true;

-- Disable/enable OIDS:
ALTER TABLE <tablename> SET WITHOUT OIDS;
ALTER TABLE <tablename> SET WITH OIDS;


-- Create pgcrypto extension:
CREATE EXTENSION pgcrypto;
SELECT * FROM pg_extension;
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

-- View active/idle database connections:
SELECT * FROM pg_stat_activity WHERE datname = '<DATABASE_NAME>';
SELECT * FROM pg_stat_activity WHERE state = 'idle' AND datname = '<DATABASE_NAME>';
SELECT * FROM pg_stat_activity WHERE state = 'active' AND datname = '<DATABASE_NAME>';
SELECT count(*) AS total_connections FROM pg_stat_activity;

-- v1
SELECT
    datname,
    client_hostname,
    query 
FROM pg_stat_activity 
WHERE state = 'idle' AND datname = '<DATABASE_NAME>';

-- v2
SELECT
    pid,
    usename AS username,
    datname AS database_name,
    client_addr AS client_address,
    application_name,
    backend_start,
    state,
    query
FROM
    pg_stat_activity;

-- v3
SELECT
    count(*) AS total_connections,
    state,
    usename AS username,
    client_addr AS client_address
FROM
    pg_stat_activity
GROUP BY
    state,
    usename,
    client_addr
ORDER BY
    total_connections DESC;

-- Terminate connections to a database from the server side:
SELECT  pg_terminate_backend(pid)
FROM  pg_stat_activity
WHERE
    datname = '<TARGET_DB_NAME>'
    AND leader_pid IS NULL;

-- Find postgres config files and max connections allowed.
SHOW config_file;
SHOW hba_file;
pg_ctl reload
SHOW MAX_CONNECTIONS;
