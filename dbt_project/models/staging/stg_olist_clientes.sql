-- customer_id en la vista = customer_unique_id del dataset original
SELECT DISTINCT ON (customer_id)
    customer_id::TEXT       AS cliente_id_origen,
    NULL::TEXT              AS nombre_cliente,
    NULL::SMALLINT          AS edad,
    NULL::VARCHAR           AS genero,
    ciudad,
    estado_provincia,
    pais,
    NULL::TEXT              AS region_geografica,
    'OLIST'                 AS origen_sistema
FROM {{ source('staging_olist', 'vw_dwh_olist_clientes') }}
WHERE customer_id IS NOT NULL
ORDER BY customer_id
