-- RetailStore no tiene fecha transaccional real.
-- Se usa '2018-01-01' como placeholder dentro del rango de dim_tiempo (2013-2018).
SELECT
    customer_id::TEXT           AS cliente_id_origen,
    producto_id_origen,
    '2018-01-01'::DATE          AS fecha_venta,
    cantidad::NUMERIC,
    precio_unitario::NUMERIC,
    monto_total::NUMERIC,
    NULL::NUMERIC               AS ganancia_neta,
    NULL::NUMERIC               AS costo_unitario,
    descuento_pct::NUMERIC,
    calificacion_item::NUMERIC,
    NULL::INTEGER               AS tiempo_entrega_dias,
    NULL::SMALLINT              AS cuotas_pago,
    compras_previas::SMALLINT,
    NULL::NUMERIC               AS flete_valor,
    metodo_pago                 AS metodo_pago_origen,
    NULL::TEXT                  AS tienda_id_origen,
    'RETAIL'                    AS origen_sistema
FROM {{ source('staging_retailsales', 'vw_dwh_retail_ventas') }}
WHERE monto_total IS NOT NULL
  AND monto_total > 0
  AND customer_id IS NOT NULL
