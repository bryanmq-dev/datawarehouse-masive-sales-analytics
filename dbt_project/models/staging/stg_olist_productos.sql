SELECT DISTINCT
    product_id::TEXT        AS producto_id_origen,
    categoria               AS nombre_producto,
    categoria,
    NULL::TEXT              AS subcategoria,
    'OLIST'                 AS origen_sistema
FROM {{ source('staging_olist', 'vw_dwh_olist_productos') }}
WHERE product_id IS NOT NULL
