SELECT
    tienda_id_origen,
    nombre_mall,
    ciudad,
    estado,
    region,
    origen_sistema
FROM {{ ref('stg_diffstore_tiendas') }}

UNION ALL

-- Fila genérica para fuentes sin tienda específica (WWI, Olist, Retail)
SELECT
    'GENERIC'                  AS tienda_id_origen,
    'Sin tienda específica'    AS nombre_mall,
    NULL::TEXT                 AS ciudad,
    NULL::TEXT                 AS estado,
    NULL::TEXT                 AS region,
    'GENERIC'                  AS origen_sistema
