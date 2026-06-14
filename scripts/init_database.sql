# /*

# Create Database and Schemas

Script Purpose:
This script creates a new database named 'salesiq_db'
and sets up the following schemas:

```
- bronze
- silver
- gold
```

WARNING:
Running the DROP DATABASE statement will permanently
delete the database and all data contained within it.

```
Make sure you have proper backups before executing.
```

=============================================================
*/

---

## -- STEP 1: DROP DATABASE (Optional)

-- Execute this while connected to the default
-- 'postgres' database.

DROP DATABASE IF EXISTS salesiq_db;

---

## -- STEP 2: CREATE DATABASE

CREATE DATABASE salesiq_db;

---

## -- STEP 3: CONNECT TO DATABASE

-- psql:
-- \c salesiq_db

---

## -- STEP 4: CREATE SCHEMAS

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;

---

## -- VERIFICATION

SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('bronze', 'silver', 'gold');
