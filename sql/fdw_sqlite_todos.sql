-- Vistas SQLite creadas en DWH de postgresql porque sqlite_fdw importa tablas, no vistas del archivo SQLite.

-- DifferentStoreSales
-- Vista: ventas DiffStore con tipos correctos y fecha parseada
CREATE OR REPLACE VIEW staging_sqlite_diff_store_sales.vw_dwh_diffstore_ventas AS
SELECT
    invoice_no AS invoice_no,
    TO_DATE(invoice_date, 'MM/DD/YYYY') AS fecha_venta,
    customer_id AS customer_id,
    gender AS genero,
    age::SMALLINT AS edad,
    category AS categoria,
    quantity::NUMERIC AS cantidad,
    selling_price_per_unit::NUMERIC AS precio_unitario,
    cost_price_per_unit::NUMERIC AS costo_unitario,
    (quantity::NUMERIC * selling_price_per_unit::NUMERIC) AS monto_total,
    ((selling_price_per_unit::NUMERIC - cost_price_per_unit::NUMERIC) * quantity::NUMERIC) AS ganancia_neta,
    payment_method AS metodo_pago,
    region AS region,
    state AS estado,
    shopping_mall AS tienda
FROM staging_sqlite_diff_store_sales."Different_stores_dataset"
WHERE invoice_date IS NOT NULL
  AND selling_price_per_unit IS NOT NULL
  AND selling_price_per_unit::NUMERIC > 0
  AND cost_price_per_unit IS NOT NULL;



CREATE OR REPLACE VIEW staging_sqlite_diff_store_sales.vw_dwh_diffstore_clientes AS
SELECT DISTINCT ON (customer_id)
    customer_id AS cliente_id_origen,
    gender AS genero,
    age::SMALLINT AS edad,
    state AS estado_provincia,
    region AS region_geografica
FROM staging_sqlite_diff_store_sales."Different_stores_dataset"
WHERE customer_id IS NOT NULL
ORDER BY customer_id, age::SMALLINT DESC NULLS LAST;


-- Vista: productos únicos DiffStore (nivel categoría)
CREATE OR REPLACE VIEW staging_sqlite_diff_store_sales.vw_dwh_diffstore_productos AS
SELECT DISTINCT
    category AS producto_id_origen,
    category AS nombre_producto,
    category AS categoria
FROM staging_sqlite_diff_store_sales."Different_stores_dataset"
WHERE category IS NOT NULL
  AND TRIM(category) <> '';


-- Vista: tiendas únicas DiffStore (shopping malls)
CREATE OR REPLACE VIEW staging_sqlite_diff_store_sales.vw_dwh_diffstore_tiendas AS
SELECT DISTINCT
    shopping_mall AS tienda_id_origen,
    shopping_mall AS nombre_mall,
    state AS estado,
    region AS region
FROM staging_sqlite_diff_store_sales."Different_stores_dataset"
WHERE shopping_mall IS NOT NULL
  AND TRIM(shopping_mall) <> '';



-- RetailStoreSales

-- Vista: ventas RetailStore con tipos correctos
CREATE OR REPLACE VIEW staging_sqlite_retail_store_sales.vw_dwh_retail_ventas AS
SELECT
    "CustomerID"::TEXT AS customer_id,
    "Age"::SMALLINT AS edad,
    "Gender" AS genero,
    "Category" AS categoria,
    "ItemPurchased" AS nombre_producto,
    "Category" || '|' || "ItemPurchased" AS producto_id_origen,
    "Amount"::NUMERIC AS monto_total,
    "Amount"::NUMERIC AS precio_unitario,
    1::NUMERIC AS cantidad,
    "Season" AS temporada_origen,
    "PaymentMethod" AS metodo_pago,
    "ItemRating"::NUMERIC(3,1) AS calificacion_item,
    "DiscountApplied(pct)"::NUMERIC(6,3) AS descuento_pct,
    "PreviousPurchases"::SMALLINT AS compras_previas,
    CURRENT_DATE AS fecha_venta
FROM staging_sqlite_retail_store_sales.store_sales
WHERE "Amount" IS NOT NULL
  AND "Amount"::NUMERIC > 0
  AND "CustomerID" IS NOT NULL;


-- Vista: clientes únicos RetailStore
CREATE OR REPLACE VIEW staging_sqlite_retail_store_sales.vw_dwh_retail_clientes AS
SELECT DISTINCT ON ("CustomerID")
    "CustomerID"::TEXT AS cliente_id_origen,
    "Age"::SMALLINT AS edad,
    "Gender" AS genero,
    NULL::TEXT AS ciudad,
    NULL::TEXT AS estado_provincia,
    NULL::TEXT AS pais,
    NULL::TEXT AS region_geografica
FROM staging_sqlite_retail_store_sales.store_sales
WHERE "CustomerID" IS NOT NULL
ORDER BY "CustomerID";


-- Vista: productos únicos RetailStore (categoría + item)
CREATE OR REPLACE VIEW staging_sqlite_retail_store_sales.vw_dwh_retail_productos AS
SELECT DISTINCT
    "Category" || '|' || "ItemPurchased" AS producto_id_origen,
    "ItemPurchased" AS nombre_producto,
    "Category" AS categoria,
    "ItemPurchased" AS subcategoria
FROM staging_sqlite_retail_store_sales.store_sales
WHERE "ItemPurchased" IS NOT NULL
  AND "Category" IS NOT NULL;


-- SUPERMARKET BRANCHES fuente comparativa externa, no se integra al DWH

-- Vista: KPIs de sucursales para comparación en Superset
CREATE OR REPLACE VIEW staging_sqlite_super_store_sales.vw_supermarket_kpis AS
SELECT
    "Store_ID"::INTEGER                 AS store_id,
    "Store_Area"::INTEGER               AS area_m2,
    "Items_Available"::INTEGER          AS items_disponibles,
    "Daily_Customer_Count"::INTEGER     AS clientes_diarios,
    "Store_Sales"::NUMERIC              AS ventas_totales,
    ROUND("Store_Sales"::NUMERIC
              / NULLIF("Daily_Customer_Count"::INTEGER, 0), 2)    AS ticket_promedio_cliente,
    ROUND("Store_Sales"::NUMERIC
              / NULLIF("Items_Available"::INTEGER, 0), 4)         AS ventas_por_item_disponible,
    NTILE(4) OVER (ORDER BY "Store_Sales"::NUMERIC)         AS cuartil_ventas
FROM staging_sqlite_super_store_sales."Stores"
WHERE "Store_Sales" IS NOT NULL
  AND "Store_Sales"::NUMERIC > 0;


SELECT COUNT(*) FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_ventas; 
SELECT COUNT(*) FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_clientes;
SELECT COUNT(*) FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_productos;
SELECT COUNT(*) FROM staging_sqlite_diff_store_sales.vw_dwh_diffstore_tiendas;
SELECT COUNT(*) FROM staging_sqlite_retail_store_sales.vw_dwh_retail_ventas;
SELECT COUNT(*) FROM staging_sqlite_retail_store_sales.vw_dwh_retail_clientes;
SELECT COUNT(*) FROM staging_sqlite_retail_store_sales.vw_dwh_retail_productos;
SELECT COUNT(*) FROM staging_sqlite_super_store_sales.vw_supermarket_kpis;
