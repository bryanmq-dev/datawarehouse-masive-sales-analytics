-- Ejecutar en SQL Server (src_sqlserver, puerto 1434)
-- Columnas origen son tipo text (importadas desde CSV)
-- JOINs usan VARCHAR(N) específico (no MAX) para compatibilidad con tds_fdw

USE master;
GO

CREATE OR ALTER VIEW dwh.vw_dwh_olist_ventas AS
SELECT
    CAST(oi.order_id          AS VARCHAR(50))   AS order_id,
    CAST(oi.order_item_id     AS VARCHAR(10))   AS order_item_id,
    CAST(oi.product_id        AS VARCHAR(50))   AS product_id,
    CAST(oi.seller_id         AS VARCHAR(50))   AS seller_id,
    CAST(c.customer_unique_id AS VARCHAR(50))   AS customer_unique_id,
    TRY_CAST(CAST(o.order_purchase_timestamp   AS VARCHAR(30)) AS DATE) AS fecha_pedido,
    TRY_CAST(CAST(oi.price                     AS VARCHAR(30)) AS DECIMAL(18,4)) AS precio_unitario,
    TRY_CAST(CAST(oi.price                     AS VARCHAR(30)) AS DECIMAL(18,4))
      + TRY_CAST(CAST(oi.freight_value         AS VARCHAR(30)) AS DECIMAL(18,4)) AS monto_total,
    TRY_CAST(CAST(oi.freight_value             AS VARCHAR(30)) AS DECIMAL(18,4)) AS flete_valor,
    CAST(op.payment_type         AS VARCHAR(30)) AS metodo_pago,
    TRY_CAST(CAST(op.payment_installments AS VARCHAR(10)) AS INT) AS cuotas_pago,
    TRY_CAST(CAST(op.payment_value        AS VARCHAR(30)) AS DECIMAL(18,4)) AS monto_pagado,
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN DATEDIFF(
            day,
            TRY_CAST(CAST(o.order_purchase_timestamp      AS VARCHAR(30)) AS DATE),
            TRY_CAST(CAST(o.order_delivered_customer_date AS VARCHAR(30)) AS DATE)
        )
        ELSE NULL
    END                                         AS tiempo_entrega_dias,
    TRY_CAST(CAST(or2.review_score AS VARCHAR(5)) AS INT) AS calificacion,
    CAST(o.order_status AS VARCHAR(20))         AS estado_pedido
FROM dwh.olist_order_items_dataset oi
JOIN dwh.olist_orders_dataset o
    ON CAST(oi.order_id AS VARCHAR(50)) = CAST(o.order_id AS VARCHAR(50))
JOIN dwh.olist_customers_dataset c
    ON CAST(o.customer_id AS VARCHAR(50)) = CAST(c.customer_id AS VARCHAR(50))
LEFT JOIN dwh.olist_order_payments_dataset op
    ON CAST(oi.order_id AS VARCHAR(50)) = CAST(op.order_id AS VARCHAR(50))
    AND TRY_CAST(CAST(op.payment_sequential AS VARCHAR(5)) AS INT) = 1
LEFT JOIN dwh.olist_order_reviews_dataset or2
    ON CAST(oi.order_id AS VARCHAR(50)) = CAST(or2.order_id AS VARCHAR(50))
WHERE CAST(o.order_status AS VARCHAR(20)) IN ('delivered', 'shipped', 'processing')
  AND TRY_CAST(CAST(oi.price AS VARCHAR(30)) AS DECIMAL(18,4)) > 0;
GO

CREATE OR ALTER VIEW dwh.vw_dwh_olist_clientes AS
SELECT DISTINCT
    CAST(c.customer_unique_id AS VARCHAR(50))   AS customer_id,
    CAST(c.customer_city      AS VARCHAR(100))  AS ciudad,
    CAST(c.customer_state     AS VARCHAR(10))   AS estado_provincia,
    'Brasil'                                    AS pais,
    TRY_CAST(CAST(g.geolocation_lat AS VARCHAR(30)) AS DECIMAL(10,6)) AS latitud,
    TRY_CAST(CAST(g.geolocation_lng AS VARCHAR(30)) AS DECIMAL(10,6)) AS longitud
FROM dwh.olist_customers_dataset c
LEFT JOIN dwh.olist_geolocation_dataset g
    ON TRY_CAST(CAST(c.customer_zip_code_prefix AS VARCHAR(10)) AS INT)
     = TRY_CAST(CAST(g.geolocation_zip_code_prefix AS VARCHAR(10)) AS INT);
GO

CREATE OR ALTER VIEW dwh.vw_dwh_olist_productos AS
SELECT
    CAST(p.product_id AS VARCHAR(50))           AS product_id,
    COALESCE(
        CAST(t.product_category_name_english AS VARCHAR(100)),
        CAST(p.product_category_name         AS VARCHAR(100)),
        'Unknown'
    )                                           AS categoria,
    COALESCE(
        CAST(t.product_category_name_english AS VARCHAR(100)),
        CAST(p.product_category_name         AS VARCHAR(100)),
        'Unknown'
    )                                           AS nombre_producto
FROM dwh.olist_products_dataset p
LEFT JOIN dwh.product_category_name_translation t
    ON CAST(p.product_category_name AS VARCHAR(100))
     = CAST(t.product_category_name AS VARCHAR(100));
GO

-- Verificar
SELECT TOP 5 * FROM dwh.vw_dwh_olist_ventas;
SELECT TOP 5 * FROM dwh.vw_dwh_olist_clientes;
SELECT TOP 5 * FROM dwh.vw_dwh_olist_productos;
