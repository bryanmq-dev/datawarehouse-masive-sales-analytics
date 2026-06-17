-- Requiere que vw_dwh_olist_ventas en SQL Server incluya customer_unique_id.
-- Si no: ejecutar fdw_sqlserver_olist.sql en SQL Server y reimportar la vista FDW.
SELECT
    customer_unique_id::TEXT        AS cliente_id_origen,
    product_id::TEXT                AS producto_id_origen,
    -- tds_fdw devuelve datetime como "Nov 27 2017 12:00:00:AM"
    TO_DATE(
        SPLIT_PART(fecha_pedido, ' ', 1) || ' ' ||
        SPLIT_PART(fecha_pedido, ' ', 2) || ' ' ||
        SPLIT_PART(fecha_pedido, ' ', 3),
        'Mon DD YYYY'
    )                               AS fecha_venta,
    1::NUMERIC                      AS cantidad,
    precio_unitario::NUMERIC,
    monto_total::NUMERIC,
    NULL::NUMERIC                   AS ganancia_neta,
    NULL::NUMERIC                   AS costo_unitario,
    NULL::NUMERIC                   AS descuento_pct,
    calificacion::NUMERIC           AS calificacion_item,
    tiempo_entrega_dias::INTEGER,
    cuotas_pago::SMALLINT,
    NULL::SMALLINT                  AS compras_previas,
    flete_valor::NUMERIC,
    metodo_pago                     AS metodo_pago_origen,
    NULL::TEXT                      AS tienda_id_origen,
    'OLIST'                         AS origen_sistema
FROM {{ source('staging_olist', 'vw_dwh_olist_ventas') }}
WHERE fecha_pedido IS NOT NULL
  AND TRIM(fecha_pedido) <> ''
  AND precio_unitario::NUMERIC > 0
