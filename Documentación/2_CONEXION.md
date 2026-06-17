# Conexión a distintos origenes

Para la extracción de datos se realiza una conexión virtual desde la base de datos resultado (DataWarehouse PostgreSQL) con las extensiones fdw, tanto para sqlserver, sqlite y otro origen postgresql.

En el caso de de MongoDB, las extensiones fdw son muy complejas de instalar y presentan fallos al ser una traducción de un modelo NoSQL a un modelo SQL clásico, por lo que se usará python y el driver de lectura de archivos fdw para ello;

## Creación de extensiones requeridas
```sql
CREATE EXTENSION IF NOT EXISTS tds_fdw;
CREATE EXTENSION IF NOT EXISTS sqlite_fdw;
CREATE EXTENSION IF NOT EXISTS postgres_fdw;
```


## Creación de servidores para origenes (SQLServer, PostgreSQL y SQLite)
```sql
CREATE SERVER sqlserver_origen
FOREIGN DATA WRAPPER tds_fdw
OPTIONS (
servername 'src_sqlserver',
port '1433',
database 'master'
);

CREATE SERVER postgresql_origen
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (
host 'src_postgres',
port '5432',
dbname 'postgres'
);

CREATE SERVER sqlite_diff_store_sales
FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS ( database '/mnt/sqlite_data/DifferentStoreSales.sqlite' );

CREATE SERVER sqlite_super_store_sales
FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS ( database '/mnt/sqlite_data/SupermarketStoreBranchesSales.sqlite' );

CREATE SERVER sqlite_retail_store_sales
FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS ( database '/mnt/sqlite_data/RetailStoreSales.sqlite' );
```

## Conexion a servidores con credenciales de cada uno de los origenes
```sql
CREATE USER MAPPING FOR brayan_admin
SERVER sqlserver_origen
OPTIONS (
username 'sa',
password 'Dwh_Brayan_2026_Enterprise*'
);

CREATE USER MAPPING FOR brayan_admin
SERVER postgresql_origen
OPTIONS (
user 'brayan_admin',
password 'super_password_123'
);
       
```


## Creación de esquemas para cada origen de datos
```sql

CREATE SCHEMA staging_sqlserver_olist;
CREATE SCHEMA staging_sqlite_diff_store_sales;
CREATE SCHEMA staging_sqlite_super_store_sales;
CREATE SCHEMA staging_sqlite_retail_store_sales;
CREATE SCHEMA staging_postgresql_world_wide_importers;
```

## Importación de esquemas (bases de datos externas) hacia esquema de PostgreSQL DWH resultado, se hace un espejo sin hacer impacto en memoria aún
```sql

IMPORT FOREIGN SCHEMA dwh
FROM SERVER sqlserver_origen
INTO staging_sqlserver_olist;

IMPORT FOREIGN SCHEMA public
FROM SERVER postgresql_origen
INTO staging_postgresql_world_wide_importers;

IMPORT FOREIGN SCHEMA main
FROM SERVER sqlite_diff_store_sales
INTO staging_sqlite_diff_store_sales;

IMPORT FOREIGN SCHEMA main
FROM SERVER sqlite_super_store_sales
INTO staging_sqlite_super_store_sales;

IMPORT FOREIGN SCHEMA main
FROM SERVER sqlite_retail_store_sales
INTO staging_sqlite_retail_store_sales;

```