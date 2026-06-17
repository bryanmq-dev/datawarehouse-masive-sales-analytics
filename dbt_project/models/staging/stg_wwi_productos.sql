SELECT
    stock_item_id::TEXT     AS producto_id_origen,
    nombre_producto,
    categoria,
    NULL::TEXT              AS subcategoria,
    'WWI'                   AS origen_sistema
FROM {{ source('staging_wwi', 'vw_dwh_productos') }}
WHERE stock_item_id IS NOT NULL
