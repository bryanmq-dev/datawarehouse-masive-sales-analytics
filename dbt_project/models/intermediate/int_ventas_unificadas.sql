-- UNION ALL de los 4 orígenes transaccionales.
-- Todos los stagings exponen el mismo esquema de columnas.
-- Esta vista nunca copia datos — solo redefine la unión virtual sobre FDW.

SELECT
    fecha_venta,
    cliente_id_origen,
    producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    ganancia_neta,
    costo_unitario,
    descuento_pct,
    calificacion_item,
    tiempo_entrega_dias,
    cuotas_pago,
    compras_previas,
    flete_valor,
    metodo_pago_origen,
    tienda_id_origen,
    origen_sistema
FROM {{ ref('stg_wwi_ventas') }}

UNION ALL

SELECT
    fecha_venta,
    cliente_id_origen,
    producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    ganancia_neta,
    costo_unitario,
    descuento_pct,
    calificacion_item,
    tiempo_entrega_dias,
    cuotas_pago,
    compras_previas,
    flete_valor,
    metodo_pago_origen,
    tienda_id_origen,
    origen_sistema
FROM {{ ref('stg_olist_ventas') }}

UNION ALL

SELECT
    fecha_venta,
    cliente_id_origen,
    producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    ganancia_neta,
    costo_unitario,
    descuento_pct,
    calificacion_item,
    tiempo_entrega_dias,
    cuotas_pago,
    compras_previas,
    flete_valor,
    metodo_pago_origen,
    tienda_id_origen,
    origen_sistema
FROM {{ ref('stg_diffstore_ventas') }}

UNION ALL

SELECT
    fecha_venta,
    cliente_id_origen,
    producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    ganancia_neta,
    costo_unitario,
    descuento_pct,
    calificacion_item,
    tiempo_entrega_dias,
    cuotas_pago,
    compras_previas,
    flete_valor,
    metodo_pago_origen,
    tienda_id_origen,
    origen_sistema
FROM {{ ref('stg_retail_ventas') }}
