-- Vistas en el origen src_postgres pre-filtrar y pre-unir datos antes de exponer via FDW

SET search_path = public;

-- VISTA PRINCIPAL: líneas de venta con contexto

CREATE OR REPLACE VIEW vw_dwh_ventas AS
SELECT
    il."invoicelineid" AS invoice_line_id,
    TO_DATE(TO_CHAR(i."invoicedate"::DATE, 'YYYY-MM-DD'), 'YYYY-MM-DD') AS fecha_venta,
    i."customerid" AS customer_id,
    il."stockitemid" AS stock_item_id,
    il."quantity" AS cantidad,
    il."unitprice" AS precio_unitario,
    il."extendedprice" AS monto_total,
    il."lineprofit" AS ganancia_neta,
    il."taxrate" AS tasa_impuesto,
    COALESCE(ct."paymentmethodid"::TEXT, 'NULL') AS payment_method_id


FROM "sales_invoicelines" il
    JOIN "sales_invoices" i  ON il."invoiceid"   = i."invoiceid"
    LEFT JOIN "sales_customertransactions" ct ON ct."invoiceid" = text(i."invoiceid") AND ct."customerid" = i."customerid"

    WHERE i."invoicedate" IS NOT NULL AND il."unitprice" > 0;

-- VISTA DE CLIENTES CON GEOGRAFÍA

CREATE OR REPLACE VIEW vw_dwh_clientes AS
SELECT
    c."customerid" AS customer_id,
    c."customername" AS nombre_cliente,
    c."standarddiscountpercentage" AS descuento_pct,
    city."cityname" AS ciudad,
    sp."stateprovincecode" AS codigo_estado,
    sp."stateprovincename" AS estado_provincia,
    sp."salesterritory" AS region_geografica,
    co."countryname" AS pais,
    co."continent" AS continente,
    city."latitude" AS latitud,
    city."longitude" AS longitud
FROM "sales_customers"          c
         LEFT JOIN "application_cities" city ON c."deliverycityid"      = city."cityid"
         LEFT JOIN "application_stateprovinces" sp  ON city."stateprovinceid"  = text(sp."stateprovinceid")
         LEFT JOIN "application_countries" co  ON sp."countryid"          = co."countryid";

-- VISTA DE PRODUCTOS CON CATEGORÍA

CREATE OR REPLACE VIEW vw_dwh_productos AS
SELECT
    si."stockitemid" AS stock_item_id,
    si."stockitemname" AS nombre_producto,
    si."unitprice" AS precio_lista,
    sg."stockgroupname" AS categoria,
    si."brand" AS marca,
    si."size" AS talla_tamanio
FROM "warehouse_stockitems" si
         JOIN "warehouse_stockitemstockgroups" sisg ON si."stockitemid" = sisg."stockitemid"
         JOIN "warehouse_stockgroups" sg   ON sisg."stockgroupid" = sg."stockgroupid";

-- VISTA DE MÉTODOS DE PAGO

CREATE OR REPLACE VIEW vw_dwh_metodos_pago AS
SELECT
    "paymentmethodid"   AS payment_method_id,
    "paymentmethodname" AS nombre_pago
FROM "application_paymentmethods";


select * from vw_dwh_ventas;

select * from vw_dwh_clientes;

select * from vw_dwh_metodos_pago;

select * from vw_dwh_productos;
