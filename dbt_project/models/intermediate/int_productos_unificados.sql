SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    origen_sistema
FROM {{ ref('stg_wwi_productos') }}

UNION ALL

SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    origen_sistema
FROM {{ ref('stg_olist_productos') }}

UNION ALL

SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    origen_sistema
FROM {{ ref('stg_diffstore_productos') }}

UNION ALL

SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    origen_sistema
FROM {{ ref('stg_retail_productos') }}
