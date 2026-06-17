{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY origen_sistema, producto_id_origen) AS producto_key,
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    origen_sistema
FROM (
    SELECT DISTINCT ON (producto_id_origen, origen_sistema)
        producto_id_origen,
        nombre_producto,
        categoria,
        subcategoria,
        origen_sistema
    FROM {{ ref('int_productos_unificados') }}
    WHERE producto_id_origen IS NOT NULL
      AND TRIM(COALESCE(nombre_producto, '')) <> ''
    ORDER BY producto_id_origen, origen_sistema, nombre_producto
) dedup
