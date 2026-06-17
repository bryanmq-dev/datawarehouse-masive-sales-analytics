{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY codigo_origen) AS origen_key,
    codigo_origen,
    nombre_completo,
    motor_bd,
    tipo_datos,
    tipo_canal,
    mercado,
    registros_aprox
FROM (VALUES
    ('DIFFSTORE', 'DifferentStoreSales',         'SQLite',     'Granular Mall',       'Offline', 'EE.UU.',        99457),
    ('OLIST',     'Brazilian E-Commerce Olist',  'SQL Server', 'Granular E-Commerce', 'Online',  'Brasil',        112650),
    ('RETAIL',    'RetailStoreSales',            'SQLite',     'Granular Retail',     'Offline', 'Genérico',      5000),
    ('WWI',       'WorldWideImporters',          'PostgreSQL', 'Granular B2B',        'B2B',     'Multinacional', 228265)
) AS t(codigo_origen, nombre_completo, motor_bd, tipo_datos, tipo_canal, mercado, registros_aprox)
