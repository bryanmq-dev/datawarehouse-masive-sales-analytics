-- DEMO 1: Conteos por staging model (datos reales desde FDW, sin copiar nada)
-- Ejecutar en DataGrip después de: dbt run --select staging
-- Esperado: ~228k WWI, ~112k OLIST, ~99k DIFFSTORE, ~5k RETAIL

SELECT 'WWI — ventas'          AS modelo, COUNT(*) AS filas FROM {{ ref('stg_wwi_ventas') }}
UNION ALL
SELECT 'WWI — clientes',         COUNT(*) FROM {{ ref('stg_wwi_clientes') }}
UNION ALL
SELECT 'WWI — productos',        COUNT(*) FROM {{ ref('stg_wwi_productos') }}
UNION ALL
SELECT 'OLIST — ventas',         COUNT(*) FROM {{ ref('stg_olist_ventas') }}
UNION ALL
SELECT 'OLIST — clientes',       COUNT(*) FROM {{ ref('stg_olist_clientes') }}
UNION ALL
SELECT 'OLIST — productos',      COUNT(*) FROM {{ ref('stg_olist_productos') }}
UNION ALL
SELECT 'DiffStore — ventas',     COUNT(*) FROM {{ ref('stg_diffstore_ventas') }}
UNION ALL
SELECT 'DiffStore — clientes',   COUNT(*) FROM {{ ref('stg_diffstore_clientes') }}
UNION ALL
SELECT 'DiffStore — productos',  COUNT(*) FROM {{ ref('stg_diffstore_productos') }}
UNION ALL
SELECT 'DiffStore — tiendas',    COUNT(*) FROM {{ ref('stg_diffstore_tiendas') }}
UNION ALL
SELECT 'Retail — ventas',        COUNT(*) FROM {{ ref('stg_retail_ventas') }}
UNION ALL
SELECT 'Retail — clientes',      COUNT(*) FROM {{ ref('stg_retail_clientes') }}
UNION ALL
SELECT 'Retail — productos',     COUNT(*) FROM {{ ref('stg_retail_productos') }}
ORDER BY modelo
