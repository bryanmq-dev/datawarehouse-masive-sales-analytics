{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (
        ORDER BY COALESCE(pais,''), COALESCE(estado_provincia,''), COALESCE(ciudad,'')
    )                           AS region_key,
    ciudad,
    estado_provincia,
    NULL::VARCHAR(10)           AS codigo_estado,
    pais,
    NULL::VARCHAR(50)           AS continente,
    region_geografica,
    NULL::DECIMAL(10,7)         AS latitud,
    NULL::DECIMAL(10,7)         AS longitud,
    origen_sistema
FROM (
    SELECT DISTINCT
        ciudad,
        estado_provincia,
        pais,
        region_geografica,
        origen_sistema
    FROM {{ ref('int_clientes_unificados') }}
    WHERE ciudad IS NOT NULL
       OR estado_provincia IS NOT NULL
       OR pais IS NOT NULL
) dedup
