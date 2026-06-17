SELECT
    tienda_id_origen,
    nombre_mall,
    NULL::TEXT      AS ciudad,
    estado,
    region,
    'DIFFSTORE'     AS origen_sistema
FROM {{ source('staging_diffsales', 'vw_dwh_diffstore_tiendas') }}
WHERE tienda_id_origen IS NOT NULL
  AND TRIM(tienda_id_origen) <> ''
