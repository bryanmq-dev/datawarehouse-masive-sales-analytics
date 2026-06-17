-- DEMO 2: Conteos de la capa intermedia (UNION ALL virtual de las 4 fuentes)
-- Ejecutar en DataGrip después de: dbt run --select intermediate
-- Total ventas esperado: ~445k filas

SELECT 'int_ventas_unificadas'    AS modelo, COUNT(*) AS filas
FROM {{ ref('int_ventas_unificadas') }}
UNION ALL
SELECT 'int_clientes_unificados', COUNT(*)
FROM {{ ref('int_clientes_unificados') }}
UNION ALL
SELECT 'int_productos_unificados', COUNT(*)
FROM {{ ref('int_productos_unificados') }}
UNION ALL
SELECT 'int_tiendas_unificadas',  COUNT(*)
FROM {{ ref('int_tiendas_unificadas') }}
ORDER BY modelo
