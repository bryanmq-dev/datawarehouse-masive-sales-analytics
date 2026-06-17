-- ============================================================
-- Consultas de Extracción contra FDW Virtuales
-- Ejecutar EN: DWH PostgreSQL (destino)
-- Requiere: extensiones FDW activas y staging schemas importados
-- Ver: 2_CONEXION.md para setup previo de servidores y user mappings
-- ============================================================

SET search_path = public;

-- ═══════════════════════════════════════════════════════════════
-- SECCIÓN 1: EXTRACCIÓN WWI (FDW postgres_fdw)
-- Staging schema: staging_postgresql_world_wide_importers
-- Las tablas FDW corresponden a las vistas vw_dwh_* creadas en el origen
-- ═══════════════════════════════════════════════════════════════

-- 1A. Productos WWI con categoría
SELECT
    stock_item_id::TEXT                 AS producto_id_origen,
    nombre_producto,
    categoria,
    'WWI'                               AS origen_sistema
FROM staging_postgresql_world_wide_importers.vw_dwh_productos
ORDER BY stock_item_id;

-- 1B. Clientes WWI con geografía completa
SELECT
    customer_id::TEXT                   AS cliente_id_origen,
    nombre_cliente,
    NULL::SMALLINT                      AS edad,
    NULL::VARCHAR                       AS genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    'WWI'                               AS origen_sistema
FROM staging_postgresql_world_wide_importers.vw_dwh_clientes;

-- 1C. Ventas WWI (hechos)
SELECT
    fecha_venta,
    customer_id::TEXT                   AS cliente_id_origen,
    stock_item_id::TEXT                 AS producto_id_origen,
    cantidad::NUMERIC,
    precio_unitario::NUMERIC,
    monto_total::NUMERIC,
    ganancia_neta::NUMERIC,
    NULL::NUMERIC                       AS costo_unitario,
    NULL::NUMERIC                       AS descuento_pct,
    NULL::NUMERIC                       AS calificacion_item,
    NULL::INTEGER                       AS tiempo_entrega_dias,
    NULL::SMALLINT                      AS cuotas_pago,
    NULL::SMALLINT                      AS compras_previas,
    NULL::NUMERIC                       AS flete_valor,
    COALESCE(payment_method_id,'NULL')  AS metodo_pago_origen,
    'WWI'                               AS origen_sistema
FROM staging_postgresql_world_wide_importers.vw_dwh_ventas
WHERE fecha_venta IS NOT NULL
  AND monto_total > 0;


-- ═══════════════════════════════════════════════════════════════
-- SECCIÓN 2: EXTRACCIÓN OLIST (FDW tds_fdw)
-- Staging schema: staging_sqlserver_olist
-- ═══════════════════════════════════════════════════════════════

-- 2A. Productos Olist
SELECT
    product_id                          AS producto_id_origen,
    nombre_producto,
    categoria,
    'OLIST'                             AS origen_sistema
FROM staging_sqlserver_olist.vw_dwh_olist_productos;

-- 2B. Clientes Olist
SELECT
    customer_id                         AS cliente_id_origen,
    NULL::TEXT                          AS nombre_cliente,
    NULL::SMALLINT                      AS edad,
    NULL::VARCHAR                       AS genero,
    ciudad,
    estado_provincia,
    pais,
    NULL::TEXT                          AS region_geografica,
    'OLIST'                             AS origen_sistema
FROM staging_sqlserver_olist.vw_dwh_olist_clientes;

-- 2C. Ventas Olist (hechos) — join a customers para traer customer_unique_id
SELECT
    v.fecha_pedido                      AS fecha_venta,
    c.customer_unique_id                AS cliente_id_origen,
    v.product_id                        AS producto_id_origen,
    1::NUMERIC                          AS cantidad,
    v.precio_unitario::NUMERIC,
    v.monto_total::NUMERIC,
    NULL::NUMERIC                       AS ganancia_neta,
    NULL::NUMERIC                       AS costo_unitario,
    NULL::NUMERIC                       AS descuento_pct,
    v.calificacion::NUMERIC             AS calificacion_item,
    v.tiempo_entrega_dias::INTEGER,
    v.cuotas_pago::SMALLINT,
    NULL::SMALLINT                      AS compras_previas,
    v.flete_valor::NUMERIC,
    v.metodo_pago                       AS metodo_pago_origen,
    'OLIST'                             AS origen_sistema
FROM staging_sqlserver_olist.vw_dwh_olist_ventas      v
JOIN staging_sqlserver_olist.olist_orders_dataset      o ON v.order_id = o.order_id
JOIN staging_sqlserver_olist.olist_customers_dataset   c ON o.customer_id = c.customer_id
WHERE v.fecha_pedido IS NOT NULL
  AND v.precio_unitario > 0;


-- ═══════════════════════════════════════════════════════════════
-- SECCIÓN 3: EXTRACCIÓN DIFFSTORE (FDW sqlite_fdw)
-- Staging schema: staging_sqlite_diff_store_sales
-- Vistas: ver fdw_03_views_sqlite_dwh.sql (ejecutar primero)
-- ═══════════════════════════════════════════════════════════════

-- 3A. Productos DiffStore
SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    'DIFFSTORE' AS origen_sistema
FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_productos;

-- 3B. Clientes DiffStore
SELECT
    cliente_id_origen,
    NULL::TEXT  AS nombre_cliente,
    edad,
    genero,
    NULL::TEXT  AS ciudad,
    estado_provincia,
    NULL::TEXT  AS pais,
    region_geografica,
    'DIFFSTORE' AS origen_sistema
FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_clientes;

-- 3C. Tiendas DiffStore (shopping malls)
SELECT
    tienda_id_origen,
    nombre_mall,
    NULL::TEXT  AS ciudad,
    estado,
    region,
    'DIFFSTORE' AS origen_sistema
FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_tiendas;

-- 3D. Ventas DiffStore (hechos)
SELECT
    fecha_venta,
    customer_id         AS cliente_id_origen,
    categoria           AS producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    ganancia_neta,
    costo_unitario,
    NULL::NUMERIC       AS descuento_pct,
    NULL::NUMERIC       AS calificacion_item,
    NULL::INTEGER       AS tiempo_entrega_dias,
    NULL::SMALLINT      AS cuotas_pago,
    NULL::SMALLINT      AS compras_previas,
    NULL::NUMERIC       AS flete_valor,
    metodo_pago         AS metodo_pago_origen,
    tienda              AS tienda_id_origen,
    'DIFFSTORE'         AS origen_sistema
FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_ventas;


-- ═══════════════════════════════════════════════════════════════
-- SECCIÓN 4: EXTRACCIÓN RETAILSTORE (FDW sqlite_fdw)
-- Staging schema: staging_sqlite_retail_store_sales
-- Vistas: ver fdw_03_views_sqlite_dwh.sql (ejecutar primero)
-- AVISO: sin fecha real — se documenta en informe sección 4.2
-- ═══════════════════════════════════════════════════════════════

-- 4A. Productos RetailStore
SELECT
    producto_id_origen,
    nombre_producto,
    categoria,
    subcategoria,
    'RETAIL' AS origen_sistema
FROM staging_sqlite_retail_store_sales.vw_dwh_retail_productos;

-- 4B. Clientes RetailStore
SELECT
    cliente_id_origen,
    NULL::TEXT  AS nombre_cliente,
    edad,
    genero,
    ciudad,
    estado_provincia,
    pais,
    region_geografica,
    'RETAIL' AS origen_sistema
FROM staging_sqlite_retail_store_sales.vw_dwh_retail_clientes;

-- 4C. Ventas RetailStore (hechos)
SELECT
    fecha_venta,
    customer_id         AS cliente_id_origen,
    producto_id_origen,
    cantidad,
    precio_unitario,
    monto_total,
    NULL::NUMERIC       AS ganancia_neta,
    NULL::NUMERIC       AS costo_unitario,
    descuento_pct,
    calificacion_item,
    NULL::INTEGER       AS tiempo_entrega_dias,
    NULL::SMALLINT      AS cuotas_pago,
    compras_previas,
    NULL::NUMERIC       AS flete_valor,
    metodo_pago         AS metodo_pago_origen,
    NULL::TEXT          AS tienda_id_origen,
    'RETAIL'            AS origen_sistema
FROM staging_sqlite_retail_store_sales.vw_dwh_retail_ventas;


-- ═══════════════════════════════════════════════════════════════
-- SECCIÓN 5: CONSULTAS COMPARATIVAS EXTERNAS
-- No cargan al DWH — se usan directamente en Superset
-- ═══════════════════════════════════════════════════════════════

-- 5A. SupermarketBranches — resumen por sucursal (benchmark externo)
SELECT
    "Store ID"              AS store_id,
    "Store_Area"            AS area_m2,
    "Items_Available"       AS items_disponibles,
    "Daily_Customer_Count"  AS clientes_diarios,
    "Store_Sales"           AS ventas_totales_historico
FROM staging_sqlite_super_store_sales."Stores"
ORDER BY "Store_Sales" DESC;

-- 5B. KPI DWH vs SupermarketBranches — comparación directa en Superset
-- Esta consulta se ejecuta en Superset uniendo ambas fuentes:
/*
  Con DWH:
    SELECT SUM(monto_total) / COUNT(DISTINCT tiempo_key) AS ventas_promedio_dia
    FROM dwh.fact_ventas_detalle f
    JOIN dwh.dim_origen o ON f.origen_key = o.origen_key
    WHERE o.tipo_canal = 'Offline'

  Con SupermarketBranches (FDW directo):
    SELECT AVG("Store_Sales") AS ventas_promedio_sucursal
    FROM staging_sqlite_super_store_sales."Stores"
*/

-- 5C. MongoDB CSV (generado por python/mongo_extract.py)
-- Una vez cargado el CSV, crear tabla temporal o FDW file:
/*
  COPY mongo_transacciones_financieras
  FROM '/mnt/mongo_exports/transactions_flat.csv'
  WITH (FORMAT CSV, HEADER TRUE);
*/

-- Consulta comparativa MongoDB vs picos de ventas retail:
/*
  SELECT
      mt.bucket_start_date::DATE                  AS fecha,
      COUNT(mt.transaction_code)                  AS transacciones_financieras,
      SUM(CASE WHEN mt.transaction_code = 'buy' THEN mt.amount ELSE 0 END) AS volumen_compra,
      SUM(CASE WHEN mt.transaction_code = 'sell' THEN mt.amount ELSE 0 END) AS volumen_venta,
      COALESCE(v.ventas_retail, 0)                AS ventas_retail_dwh
  FROM mongo_transacciones_financieras mt
  LEFT JOIN (
      SELECT t.fecha, SUM(f.monto_total) AS ventas_retail
      FROM dwh.fact_ventas_detalle f
      JOIN dwh.dim_tiempo t ON f.tiempo_key = t.tiempo_key
      GROUP BY t.fecha
  ) v ON mt.bucket_start_date::DATE = v.fecha
  GROUP BY mt.bucket_start_date::DATE, v.ventas_retail
  ORDER BY fecha;
*/
