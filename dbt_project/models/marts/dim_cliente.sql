{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY origen_sistema, cliente_id_origen) AS cliente_key,
    cliente_id_origen,
    nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    origen_sistema
FROM (
    SELECT DISTINCT ON (cliente_id_origen, origen_sistema)
        cliente_id_origen,
        nombre_cliente,
        edad,
        genero,
        ciudad,
        estado_provincia,
        pais,
        region_geografica,
        origen_sistema
    FROM {{ ref('int_clientes_unificados') }}
    WHERE cliente_id_origen IS NOT NULL
    ORDER BY cliente_id_origen, origen_sistema, nombre_cliente NULLS LAST
) dedup
