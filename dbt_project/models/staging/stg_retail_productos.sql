SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    'RETAIL'    AS origen_sistema
FROM {{ source('staging_retailsales', 'vw_dwh_retail_productos') }}
WHERE producto_id_origen IS NOT NULL
  AND TRIM(producto_id_origen) <> ''
