SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    NULL::TEXT      AS subcategoria,
    'DIFFSTORE'     AS origen_sistema
FROM {{ source('staging_diffsales', 'vw_dwh_diffstore_productos') }}
WHERE producto_id_origen IS NOT NULL
  AND TRIM(producto_id_origen) <> ''
