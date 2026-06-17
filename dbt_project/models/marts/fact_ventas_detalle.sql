{{ config(materialized='table') }}

WITH
ventas  AS (SELECT * FROM {{ ref('int_ventas_unificadas') }}),
dt      AS (SELECT tiempo_key, fecha       FROM {{ ref('dim_tiempo') }}),
dp      AS (SELECT producto_key, producto_id_origen, origen_sistema
            FROM {{ ref('dim_producto') }}),
dc      AS (SELECT cliente_key,  cliente_id_origen,  origen_sistema
            FROM {{ ref('dim_cliente') }}),
dm      AS (SELECT metodo_pago_key, tipo_pago_origen, origen_sistema
            FROM {{ ref('dim_metodo_pago') }}),
dcanal  AS (SELECT canal_key, subcategoria_canal FROM {{ ref('dim_canal') }}),
dtienda AS (SELECT tienda_key, tienda_id_origen, origen_sistema
            FROM {{ ref('dim_tienda') }}),
dorigen AS (SELECT origen_key, codigo_origen     FROM {{ ref('dim_origen') }}),

-- Surrogate key de la tienda genérica (para fuentes sin tienda)
generic_tienda AS (
    SELECT tienda_key
    FROM {{ ref('dim_tienda') }}
    WHERE tienda_id_origen = 'GENERIC'
      AND origen_sistema   = 'GENERIC'
)

SELECT
    dt.tiempo_key,
    dp.producto_key,
    dc.cliente_key,
    NULL::INTEGER                                               AS region_key,
    dm.metodo_pago_key,
    dcanal.canal_key,
    COALESCE(dtienda.tienda_key, gt.tienda_key)                AS tienda_key,
    dorigen.origen_key,
    v.cantidad,
    v.precio_unitario,
    v.monto_total,
    v.costo_unitario,
    v.ganancia_neta,
    v.descuento_pct,
    v.calificacion_item,
    v.tiempo_entrega_dias,
    v.cuotas_pago,
    v.compras_previas,
    v.flete_valor
FROM ventas v
CROSS JOIN generic_tienda gt

JOIN dt
    ON v.fecha_venta = dt.fecha

JOIN dp
    ON  v.producto_id_origen = dp.producto_id_origen
    AND v.origen_sistema     = dp.origen_sistema

JOIN dc
    ON  v.cliente_id_origen = dc.cliente_id_origen
    AND v.origen_sistema    = dc.origen_sistema

JOIN dm
    ON  v.metodo_pago_origen = dm.tipo_pago_origen
    AND v.origen_sistema     = dm.origen_sistema

JOIN dcanal
    ON dcanal.subcategoria_canal = CASE v.origen_sistema
        WHEN 'WWI'       THEN 'Manufactura-Distribución'
        WHEN 'OLIST'     THEN 'E-Commerce'
        WHEN 'RETAIL'    THEN 'Tienda Retail'
        WHEN 'DIFFSTORE' THEN 'Centro Comercial'
    END

LEFT JOIN dtienda
    ON  v.tienda_id_origen = dtienda.tienda_id_origen
    AND v.origen_sistema   = dtienda.origen_sistema

JOIN dorigen
    ON v.origen_sistema = dorigen.codigo_origen
