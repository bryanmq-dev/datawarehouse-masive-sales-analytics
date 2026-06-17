SELECT
    cliente_id_origen,
    nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    origen_sistema
FROM {{ ref('stg_wwi_clientes') }}

UNION ALL

SELECT
    cliente_id_origen,
    nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    origen_sistema
FROM {{ ref('stg_olist_clientes') }}

UNION ALL

SELECT
    cliente_id_origen,
    nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    origen_sistema
FROM {{ ref('stg_diffstore_clientes') }}

UNION ALL

SELECT
    cliente_id_origen,
    nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    origen_sistema
FROM {{ ref('stg_retail_clientes') }}
