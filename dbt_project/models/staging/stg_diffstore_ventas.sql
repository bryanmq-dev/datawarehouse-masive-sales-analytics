SELECT
    customer_id::TEXT       AS cliente_id_origen,
    categoria               AS producto_id_origen,
    fecha_venta::DATE,
    cantidad::NUMERIC,
    precio_unitario::NUMERIC,
    monto_total::NUMERIC,
    ganancia_neta::NUMERIC,
    costo_unitario::NUMERIC,
    NULL::NUMERIC           AS descuento_pct,
    NULL::NUMERIC           AS calificacion_item,
    NULL::INTEGER           AS tiempo_entrega_dias,
    NULL::SMALLINT          AS cuotas_pago,
    NULL::SMALLINT          AS compras_previas,
    NULL::NUMERIC           AS flete_valor,
    metodo_pago             AS metodo_pago_origen,
    tienda                  AS tienda_id_origen,
    'DIFFSTORE'             AS origen_sistema
FROM {{ source('staging_diffsales', 'vw_dwh_diffstore_ventas') }}
WHERE fecha_venta IS NOT NULL
  AND monto_total > 0
