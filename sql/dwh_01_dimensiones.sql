-- Creación de Dimensiones

CREATE SCHEMA IF NOT EXISTS dwh;
SET search_path = dwh;

-- DIM_TIEMPO

CREATE TABLE IF NOT EXISTS dim_tiempo (
    tiempo_key SERIAL PRIMARY KEY,
    fecha DATE NOT NULL UNIQUE,
    dia SMALLINT NOT NULL CHECK (dia BETWEEN 1 AND 31),
    semana SMALLINT NOT NULL CHECK (semana BETWEEN 1 AND 53),
    mes SMALLINT NOT NULL CHECK (mes BETWEEN 1 AND 12),
    trimestre SMALLINT NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
    anio SMALLINT NOT NULL,
    nombre_dia VARCHAR(15) NOT NULL,
    nombre_mes VARCHAR(15) NOT NULL,
    temporada VARCHAR(15) NOT NULL CHECK (temporada IN ('Primavera','Verano','Otoño','Invierno')),
    es_fin_semana BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_tiempo_anio_mes  ON dim_tiempo (anio, mes);
CREATE INDEX IF NOT EXISTS idx_tiempo_temporada ON dim_tiempo (temporada);

-- Poblar dim_tiempo para el rango completo de las fuentes utilizadas (2013-01-01 a 2018-12-31)
INSERT INTO dim_tiempo (fecha, dia, semana, mes, trimestre, anio, nombre_dia, nombre_mes, temporada, es_fin_semana)
SELECT
    d::DATE AS fecha,
    EXTRACT(DAY FROM d)::SMALLINT AS dia,
    EXTRACT(WEEK FROM d)::SMALLINT AS semana,
    EXTRACT(MONTH FROM d)::SMALLINT AS mes,
    EXTRACT(QUARTER FROM d)::SMALLINT AS trimestre,
    EXTRACT(YEAR FROM d)::SMALLINT AS anio,
    TO_CHAR(d, 'TMDay') AS nombre_dia,
    TO_CHAR(d, 'TMMonth') AS nombre_mes,
    CASE
        WHEN EXTRACT(MONTH FROM d) IN (3,4,5)  THEN 'Primavera'
        WHEN EXTRACT(MONTH FROM d) IN (6,7,8)  THEN 'Verano'
        WHEN EXTRACT(MONTH FROM d) IN (9,10,11) THEN 'Otoño'
        ELSE 'Invierno'
        END
        AS temporada,

    EXTRACT(ISODOW FROM d) >= 6 AS es_fin_semana
FROM generate_series('2013-01-01'::DATE, '2018-12-31'::DATE, '1 day'::INTERVAL) d
ON CONFLICT (fecha) DO NOTHING;


-- DIM_PRODUCTO

CREATE TABLE IF NOT EXISTS dim_producto (
    producto_key SERIAL PRIMARY KEY,
    producto_id_origen VARCHAR(100) NOT NULL,
    nombre_producto VARCHAR(255) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    subcategoria VARCHAR(100),
    origen_sistema VARCHAR(20)  NOT NULL CHECK (origen_sistema IN ('WWI','OLIST','RETAIL','DIFFSTORE')),
    UNIQUE (producto_id_origen, origen_sistema)
);

CREATE INDEX IF NOT EXISTS idx_producto_categoria ON dim_producto (categoria);
CREATE INDEX IF NOT EXISTS idx_producto_origen    ON dim_producto (origen_sistema);


-- DIM_CLIENTE

CREATE TABLE IF NOT EXISTS dim_cliente (
   cliente_key SERIAL PRIMARY KEY,
   cliente_id_origen VARCHAR(100) NOT NULL,
   nombre_cliente VARCHAR(255),
   edad SMALLINT CHECK (edad BETWEEN 0 AND 120),
   genero VARCHAR(20) CHECK (genero IN ('Male','Female','No informado')),
   ciudad VARCHAR(100),
   estado_provincia VARCHAR(100),
   pais VARCHAR(100),
   region_geografica VARCHAR(100),
   origen_sistema VARCHAR(20) NOT NULL CHECK (origen_sistema IN ('WWI','OLIST','RETAIL','DIFFSTORE')),
   UNIQUE (cliente_id_origen, origen_sistema)
);

CREATE INDEX IF NOT EXISTS idx_cliente_genero ON dim_cliente (genero);
CREATE INDEX IF NOT EXISTS idx_cliente_geo ON dim_cliente (estado_provincia, pais);
CREATE INDEX IF NOT EXISTS idx_cliente_origen ON dim_cliente (origen_sistema);


-- DIM_REGION

CREATE TABLE IF NOT EXISTS dim_region (
   region_key SERIAL PRIMARY KEY,
   ciudad VARCHAR(100),
   estado_provincia VARCHAR(100),
   codigo_estado VARCHAR(10),
   pais VARCHAR(100),
   continente VARCHAR(50),
   region_geografica VARCHAR(100),
   latitud DECIMAL(10,7),
   longitud DECIMAL(10,7),
   origen_sistema VARCHAR(20) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_region_geo ON dim_region (ciudad, estado_provincia, pais);


-- DIM_METODO_PAGO

CREATE TABLE IF NOT EXISTS dim_metodo_pago (
   metodo_pago_key SERIAL PRIMARY KEY,
   tipo_pago_normalizado VARCHAR(50) NOT NULL,
   tipo_pago_origen VARCHAR(50) NOT NULL,
   acepta_cuotas BOOLEAN NOT NULL DEFAULT FALSE,
   origen_sistema VARCHAR(20) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_pago_tipo ON dim_metodo_pago (tipo_pago_normalizado);

-- Seed de valores conocidos por origen
INSERT INTO dim_metodo_pago (tipo_pago_normalizado, tipo_pago_origen, acepta_cuotas, origen_sistema) VALUES
('Efectivo', 'Cash', FALSE, 'WWI'),
('Tarjeta Crédito', 'Credit Card', FALSE, 'WWI'),
('Transferencia', 'EFT', FALSE, 'WWI'),
('Cheque', 'Check', FALSE, 'WWI'),
('Tarjeta Crédito', 'credit_card', TRUE,  'OLIST'),
('Boleto', 'boleto', FALSE, 'OLIST'),
('Voucher', 'voucher', FALSE, 'OLIST'),
('Tarjeta Débito', 'debit_card', FALSE, 'OLIST'),
('Tarjeta Crédito', 'Credit Card', FALSE, 'RETAIL'),
('Efectivo', 'Cash', FALSE, 'RETAIL'),
('Tarjeta Débito', 'Debit Card', FALSE, 'RETAIL'),
('Otro', 'Card', FALSE, 'RETAIL'),
('Tarjeta Crédito', 'Credit Card', FALSE, 'DIFFSTORE'),
('Efectivo', 'Cash', FALSE, 'DIFFSTORE'),
('Tarjeta Débito', 'Debit Card', FALSE, 'DIFFSTORE')
ON CONFLICT DO NOTHING;


-- DIM_CANAL

CREATE TABLE IF NOT EXISTS dim_canal (
    canal_key SERIAL PRIMARY KEY,
    tipo_canal VARCHAR(20) NOT NULL CHECK (tipo_canal IN ('Online','Offline','B2B')),
    subcategoria_canal VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

INSERT INTO dim_canal (tipo_canal, subcategoria_canal, descripcion) VALUES
('B2B', 'Manufactura-Distribución', 'Ventas mayoristas multinacionales — WorldWideImporters'),
('Online', 'E-Commerce', 'Ventas por plataforma digital — Brazilian Olist'),
('Offline', 'Tienda Retail', 'Ventas presenciales en tienda — RetailStoreSales'),
('Offline', 'Centro Comercial', 'Ventas presenciales en mall — DifferentStoreSales')
ON CONFLICT DO NOTHING;


-- DIM_TIENDA

CREATE TABLE IF NOT EXISTS dim_tienda (
    tienda_key          SERIAL       PRIMARY KEY,
    tienda_id_origen    VARCHAR(100) NOT NULL,
    nombre_mall         VARCHAR(200),
    ciudad              VARCHAR(100),
    estado              VARCHAR(100),
    region              VARCHAR(100),
    origen_sistema      VARCHAR(20)  NOT NULL,
    UNIQUE (tienda_id_origen, origen_sistema)
);

-- Tienda genérica para fuentes sin dato de tienda
INSERT INTO dim_tienda (tienda_id_origen, nombre_mall, origen_sistema)
VALUES ('GENERIC', 'Sin tienda específica', 'GENERIC')
ON CONFLICT DO NOTHING;


-- DIM_ORIGEN

CREATE TABLE IF NOT EXISTS dim_origen (
    origen_key      SERIAL      PRIMARY KEY,
    codigo_origen   VARCHAR(20) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    motor_bd        VARCHAR(50) NOT NULL,
    tipo_datos      VARCHAR(50) NOT NULL,
    tipo_canal      VARCHAR(20) NOT NULL,
    mercado         VARCHAR(50) NOT NULL,
    registros_aprox INTEGER
);

INSERT INTO dim_origen (codigo_origen, nombre_completo, motor_bd, tipo_datos, tipo_canal, mercado, registros_aprox) VALUES
('WWI', 'WorldWideImporters', 'PostgreSQL', 'Granular B2B', 'B2B', 'Multinacional', 228265),
('OLIST', 'Brazilian E-Commerce Olist', 'SQL Server', 'Granular E-Commerce', 'Online',  'Brasil', 112650),
('RETAIL', 'RetailStoreSales', 'SQLite', 'Granular Retail', 'Offline', 'Genérico', 5000),
('DIFFSTORE', 'DifferentStoreSales', 'SQLite', 'Granular Mall', 'Offline', 'EE.UU.', 99457)
ON CONFLICT DO NOTHING;
