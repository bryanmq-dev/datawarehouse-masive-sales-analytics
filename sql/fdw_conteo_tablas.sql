DO $$
    DECLARE
        v_count BIGINT;
        v_grand_total BIGINT := 0;
    BEGIN

        CREATE TEMP TABLE IF NOT EXISTS final_row_census (
                                                             orden SERIAL,
                                                             origen_esquema TEXT,
                                                             nombre_tabla TEXT,
                                                             cantidad_filas BIGINT
        ) ON COMMIT DROP;

        BEGIN
            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_orderlines' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_orderlines', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_invoicelines' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_invoicelines', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_customertransactions' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_customertransactions', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_orders' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_orders', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_invoices' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_invoices', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_cities' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_cities', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.purchasing_purchaseorderlines' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'purchasing_purchaseorderlines', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.purchasing_suppliertransactions' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'purchasing_suppliertransactions', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.purchasing_purchaseorders' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'purchasing_purchaseorders', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_people' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_people', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_customers' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_customers', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_countries' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_countries', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_stateprovinces' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_stateprovinces', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.purchasing_suppliers' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'purchasing_suppliers', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_transactiontypes' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_transactiontypes', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_deliverymethods' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_deliverymethods', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.purchasing_suppliercategories' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'purchasing_suppliercategories', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_customercategories' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_customercategories', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.application_paymentmethods' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'application_paymentmethods', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_postgresql_world_wide_importers.sales_buyinggroups' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_postgresql_world_wide_importers', 'sales_buyinggroups', v_count); v_grand_total := v_grand_total + v_count;
        EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Fallo en alguna tabla de WWI Postgres'; END;

        BEGIN
            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_customers_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_customers_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_geolocation_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_geolocation_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_order_items_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_order_items_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_order_payments_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_order_payments_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_order_reviews_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_order_reviews_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_orders_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_orders_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_products_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_products_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.olist_sellers_dataset' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'olist_sellers_dataset', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlserver_olist.product_category_name_translation' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlserver_olist', 'product_category_name_translation', v_count); v_grand_total := v_grand_total + v_count;
        EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Fallo en alguna tabla de Olist SQL Server'; END;


        BEGIN
            EXECUTE 'SELECT COUNT(*) FROM staging_sqlite_retail_store_sales.store_sales' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlite_retail_store_sales', 'store_sales', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlite_super_store_sales.stores' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlite_super_store_sales', 'stores', v_count); v_grand_total := v_grand_total + v_count;

            EXECUTE 'SELECT COUNT(*) FROM staging_sqlite_diff_store_sales.different_stores_data_v2' INTO v_count;
            INSERT INTO final_row_census (origen_esquema, nombre_tabla, cantidad_filas) VALUES ('staging_sqlite_diff_store_sales', 'different_stores_data_v2', v_count); v_grand_total := v_grand_total + v_count;
        EXCEPTION WHEN OTHERS THEN RAISE NOTICE 'Fallo en alguna tabla de SQLite'; END;


        FOR v_count IN SELECT cantidad_filas FROM final_row_census ORDER BY cantidad_filas DESC LOOP
                -- Bucle para formatear salida
            END LOOP;

        DECLARE
            r RECORD;
        BEGIN
            FOR r IN SELECT * FROM final_row_census ORDER BY cantidad_filas DESC LOOP
                    RAISE NOTICE 'Esquema: % | Tabla: % --> Filas: %', r.origen_esquema, r.nombre_tabla, r.cantidad_filas;
                END LOOP;
        END;

        RAISE NOTICE '=========================================================================================';
        RAISE NOTICE ' >>> SUMATORIA INTEGRAL DE DATOS MASIVOS (GRAND TOTAL): % FILAS <<<', v_grand_total;
        RAISE NOTICE '=========================================================================================';
SELECT 'transactions_flat' AS tabla, COUNT(*) AS filas FROM staging_mongo.transactions_flat
UNION ALL
SELECT 'customers_flat',  COUNT(*) FROM staging_mongo.customers_flat
UNION ALL
SELECT 'accounts_flat',   COUNT(*) FROM staging_mongo.accounts_flat;
    END $$;
