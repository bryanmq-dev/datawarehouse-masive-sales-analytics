SELECT
    cliente_id_origen::TEXT,
    NULL::TEXT              AS nombre_cliente,
    edad::SMALLINT,
    CASE genero
        WHEN 'Male'   THEN 'Male'
        WHEN 'Female' THEN 'Female'
        ELSE 'No informado'
    END                     AS genero,
    NULL::TEXT              AS ciudad,
    estado_provincia,
    NULL::TEXT              AS pais,
    region_geografica,
    'DIFFSTORE'             AS origen_sistema
FROM {{ source('staging_diffsales', 'vw_dwh_diffstore_clientes') }}
WHERE cliente_id_origen IS NOT NULL
