-- Common commands:
\l
\du
\dt
\ds
\c
\q

-- Connection:
psql -U username -h host -p port -W -d database_name
pg_dump -U username -h host -p port -d database_name -f output_file.sql

-- Create/drop database/roles.
CREATE ROLE role_name WITH LOGIN SUPERUSER PASSWORD 'password' CONNECTION LIMIT -1;
CREATE ROLE role_name WITH LOGIN PASSWORD 'password' CONNECTION LIMIT -1;
CREATE DATABASE database_name WITH OWNER = role_name ENCODING = 'UTF8' CONNECTION LIMIT = -1;
DROP DATABASE database_name;

-- Import/export a database:

psql database_name < dump_file.sql
pg_dump database_name > dump_file.sql

-- Find postgres config files.
SHOW config_file;
SHOW hba_file;
pg_ctl reload

-- Alter roles and privileges:
ALTER ROLE user_name RENAME TO new_user_name;
ALTER USER user_name WITH PASSWORD 'password';
ALTER TABLE table_name OWNER TO new_owner;

GRANT ALL PRIVILEGES ON DATABASE database_name TO user;
GRANT CONNECT ON DATABASE database_name TO role_name;
GRANT CONNECT ON DATABASE mydb TO user1, user2;
GRANT USAGE ON SCHEMA public TO user1, user2;
GRANT SELECT ON TABLE tablename TO user1, user2;
GRANT INSERT, UPDATE, DELETE ON TABLE tablename TO user1;

REVOKE CONNECT ON DATABASE mydb FROM user1, user2;
REVOKE USAGE ON SCHEMA public FROM user1, user2;
REVOKE SELECT ON TABLE tablename FROM user1, user2;
REVOKE INSERT, UPDATE, DELETE ON TABLE tablename FROM user1;
REVOKE CONNECT ON DATABASE your_database FROM PUBLIC;

-- Tc and CTC = ALL PRIVILEGES
-- c = CONNECT
-- https://www.postgresql.org/docs/current/ddl-priv.html
-- https://docs.digitalocean.com/products/databases/postgresql/how-to/modify-user-privileges/

SELECT * FROM information_schema.columns WHERE table_name = 'your_table_name';

-- Show privileges for a specific user on databases:
SELECT datname, has_database_privilege(grantee, datname, privilege_type) AS privilege
FROM pg_database
CROSS JOIN pg_roles
WHERE rolname = 'your_username';

-- Show privileges for a specific user on schemas:
SELECT schema_name, has_schema_privilege(grantee, schema_name, privilege_type) AS privilege
FROM information_schema.schemata
CROSS JOIN pg_roles
WHERE rolname = 'your_username';

-- Show privileges for a specific user on tables:
SELECT table_schema, table_name, privilege_type
FROM information_schema.table_privileges
WHERE grantee = 'your_username';

-- Show privileges for a specific user on columns:
SELECT table_schema, table_name, column_name, privilege_type
FROM information_schema.column_privileges
WHERE grantee = 'your_username';

-- Checking for Data in a Specific Schema:
SELECT schemaname, tablename, reltuples
FROM pg_stat_user_tables
WHERE schemaname = 'your_schema';

-- Checking for Data in the Entire Database:
SELECT schemaname, tablename, reltuples
FROM pg_stat_all_tables;

-- List all schemas in a PostgreSQL database
SELECT schema_name
FROM information_schema.schemata;

-- pgcrypto extension:
CREATE EXTENSION pgcrypto;
SELECT * FROM pg_extension;
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

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