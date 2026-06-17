{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY origen_sistema, tienda_id_origen) AS tienda_key,
    tienda_id_origen,
    nombre_mall,
    ciudad,
    estado,
    region,
    origen_sistema
FROM {{ ref('int_tiendas_unificadas') }}
