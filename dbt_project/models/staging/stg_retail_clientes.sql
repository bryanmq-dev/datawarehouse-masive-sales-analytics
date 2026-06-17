SELECT
    cliente_id_origen::TEXT,
    NULL::TEXT              AS nombre_cliente,
    edad::SMALLINT,
    CASE genero
        WHEN 'Male'   THEN 'Male'
        WHEN 'Female' THEN 'Female'
        ELSE 'No informado'
    END                     AS genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    'RETAIL'                AS origen_sistema
FROM {{ source('staging_retailsales', 'vw_dwh_retail_clientes') }}
WHERE cliente_id_origen IS NOT NULL
