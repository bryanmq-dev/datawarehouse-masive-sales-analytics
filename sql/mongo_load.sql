-- Archivos fuente: /mnt/mongo_exports/*.csv

CREATE SCHEMA IF NOT EXISTS staging_mongo;

CREATE TABLE IF NOT EXISTS staging_mongo.transactions_flat (
    account_id        INTEGER,
    transaction_count NUMERIC,
    bucket_start_date DATE,
    bucket_end_date   DATE,
    tx_date           DATE,
    amount            NUMERIC,
    transaction_code  VARCHAR(10),
    symbol            VARCHAR(20),
    price             NUMERIC,
    total             NUMERIC
);

TRUNCATE staging_mongo.transactions_flat;

COPY staging_mongo.transactions_flat
FROM '/mnt/mongo_exports/transactions_flat.csv'
WITH (FORMAT CSV, HEADER TRUE);

CREATE TABLE IF NOT EXISTS staging_mongo.customers_flat (
    username   VARCHAR(100),
    name       VARCHAR(200),
    email      VARCHAR(200),
    active     BOOLEAN,
    birthdate  DATE,
    tier       VARCHAR(50),
    n_accounts INTEGER
);

TRUNCATE staging_mongo.customers_flat;

COPY staging_mongo.customers_flat
FROM '/mnt/mongo_exports/customers_flat.csv'
WITH (FORMAT CSV, HEADER TRUE, NULL '');

CREATE TABLE IF NOT EXISTS staging_mongo.accounts_flat (
    account_id INTEGER,
    "limit"    NUMERIC,
    products   TEXT,
    n_products INTEGER
);

TRUNCATE staging_mongo.accounts_flat;

COPY staging_mongo.accounts_flat
FROM '/mnt/mongo_exports/accounts_flat.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- Verificación rápida
SELECT 'transactions_flat' AS tabla, COUNT(*) AS filas FROM staging_mongo.transactions_flat
UNION ALL
SELECT 'customers_flat',  COUNT(*) FROM staging_mongo.customers_flat
UNION ALL
SELECT 'accounts_flat',   COUNT(*) FROM staging_mongo.accounts_flat;
