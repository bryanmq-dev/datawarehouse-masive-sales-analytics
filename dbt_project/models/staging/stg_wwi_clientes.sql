SELECT
    customer_id::TEXT       AS cliente_id_origen,
    nombre_cliente,
    NULL::SMALLINT          AS edad,
    NULL::VARCHAR           AS genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    'WWI'                   AS origen_sistema
FROM {{ source('staging_wwi', 'vw_dwh_clientes') }}
WHERE customer_id IS NOT NULL
