SELECT
    v.invoice_line_id::TEXT,
    v.fecha_venta::DATE,
    v.customer_id::TEXT                       AS cliente_id_origen,
    v.stock_item_id::TEXT                     AS producto_id_origen,
    v.cantidad::NUMERIC,
    v.precio_unitario::NUMERIC,
    v.monto_total::NUMERIC,
    v.ganancia_neta::NUMERIC,
    NULL::NUMERIC                             AS costo_unitario,
    NULL::NUMERIC                             AS descuento_pct,
    NULL::NUMERIC                             AS calificacion_item,
    NULL::INTEGER                             AS tiempo_entrega_dias,
    NULL::SMALLINT                            AS cuotas_pago,
    NULL::SMALLINT                            AS compras_previas,
    NULL::NUMERIC                             AS flete_valor,
    COALESCE(pm.nombre_pago, 'NULL')          AS metodo_pago_origen,
    NULL::TEXT                                AS tienda_id_origen,
    'WWI'                                     AS origen_sistema
FROM {{ source('staging_wwi', 'vw_dwh_ventas') }} v
LEFT JOIN {{ source('staging_wwi', 'vw_dwh_metodos_pago') }} pm
    ON v.payment_method_id = pm.payment_method_id::TEXT
WHERE v.fecha_venta IS NOT NULL
  AND v.monto_total::NUMERIC > 0
