-- Creación Tabla de Hechos

SET search_path = dwh;

-- FACT_VENTAS_DETALLE

CREATE TABLE IF NOT EXISTS fact_ventas_detalle (
    venta_key BIGSERIAL PRIMARY KEY,

    -- Claves foráneas a dimensiones (subrrogadas
    tiempo_key INTEGER NOT NULL REFERENCES dim_tiempo(tiempo_key),
    producto_key INTEGER NOT NULL REFERENCES dim_producto(producto_key),
    cliente_key INTEGER NOT NULL REFERENCES dim_cliente(cliente_key),
    region_key INTEGER REFERENCES dim_region(region_key),       -- NULL para RetailStore
    metodo_pago_key INTEGER NOT NULL REFERENCES dim_metodo_pago(metodo_pago_key),
    canal_key INTEGER NOT NULL REFERENCES dim_canal(canal_key),
    tienda_key INTEGER REFERENCES dim_tienda(tienda_key),        -- NULL para WWI, Olist
    origen_key INTEGER NOT NULL REFERENCES dim_origen(origen_key),

    -- Medidas aditivas (presentes en todos los orígenes)
    cantidad            NUMERIC(12,3) NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario     NUMERIC(18,4) NOT NULL CHECK (precio_unitario >= 0),
    monto_total         NUMERIC(18,4) NOT NULL CHECK (monto_total >= 0),

    -- Medidas parciales (nullable por diseño, ver diccionario de datos)

    -- Solo DiffStore (original dataset con cost_price_per_unit)
    costo_unitario      NUMERIC(18,4) CHECK (costo_unitario >= 0),

    -- WWI: LineProfit | DiffStore: (precio-costo)*qty calculado en dbt
    ganancia_neta       NUMERIC(18,4),

    -- RetailStore: DiscountApplied(%) | WWI: StandardDiscountPercentage
    descuento_pct       NUMERIC(6,3)  CHECK (descuento_pct BETWEEN 0 AND 100),

    -- RetailStore: ItemRating | Olist: review_score (join opcional)
    calificacion_item   NUMERIC(3,1)  CHECK (calificacion_item BETWEEN 1 AND 5),

    -- Solo Olist: order_delivered_customer_date - order_purchase_timestamp
    tiempo_entrega_dias INTEGER       CHECK (tiempo_entrega_dias >= 0),

    -- Solo Olist: payment_installments
    cuotas_pago         SMALLINT      CHECK (cuotas_pago >= 1),

    -- Solo RetailStore: PreviousPurchases
    compras_previas     SMALLINT      CHECK (compras_previas >= 0),

    -- Solo Olist: freight_value
    flete_valor         NUMERIC(18,4) CHECK (flete_valor >= 0)
);

CREATE INDEX IF NOT EXISTS idx_fact_tiempo ON fact_ventas_detalle (tiempo_key);
CREATE INDEX IF NOT EXISTS idx_fact_producto ON fact_ventas_detalle (producto_key);
CREATE INDEX IF NOT EXISTS idx_fact_cliente ON fact_ventas_detalle (cliente_key);
CREATE INDEX IF NOT EXISTS idx_fact_canal ON fact_ventas_detalle (canal_key);
CREATE INDEX IF NOT EXISTS idx_fact_origen ON fact_ventas_detalle (origen_key);
CREATE INDEX IF NOT EXISTS idx_fact_tiempo_canal ON fact_ventas_detalle (tiempo_key, canal_key);
CREATE INDEX IF NOT EXISTS idx_fact_tiempo_origen ON fact_ventas_detalle (tiempo_key, origen_key);
CREATE INDEX IF NOT EXISTS idx_fact_monto ON fact_ventas_detalle (monto_total);


-- ─── VISTAS ANALÍTICAS (sobre el DWH ya cargado) ─────────────

-- Vista: ventas diarias por canal (para comparar con SupermarketBranches)
CREATE OR REPLACE VIEW dwh.v_ventas_diarias_canal AS
SELECT
    t.fecha,
    t.anio,
    t.mes,
    t.trimestre,
    t.temporada,
    c.tipo_canal,
    c.subcategoria_canal,
    o.codigo_origen,
    COUNT(*) AS transacciones,
    SUM(f.cantidad) AS unidades_vendidas,
    SUM(f.monto_total) AS ventas_totales,
    AVG(f.monto_total) AS ticket_promedio,
    SUM(f.ganancia_neta) AS ganancia_total,
    AVG(f.tiempo_entrega_dias) AS lead_time_promedio
FROM fact_ventas_detalle f
         JOIN dim_tiempo t ON f.tiempo_key = t.tiempo_key
         JOIN dim_canal c ON f.canal_key = c.canal_key
         JOIN dim_origen o ON f.origen_key = o.origen_key
GROUP BY t.fecha, t.anio, t.mes, t.trimestre, t.temporada,c.tipo_canal, c.subcategoria_canal, o.codigo_origen;


-- Vista: ventas por categoría de producto y canal
CREATE OR REPLACE VIEW dwh.v_ventas_producto_canal AS
SELECT
    p.categoria,
    p.nombre_producto,
    p.origen_sistema AS origen_producto,
    c.tipo_canal,
    t.anio,
    t.mes,
    t.temporada,
    COUNT(*) AS transacciones,
    SUM(f.cantidad) AS unidades,
    SUM(f.monto_total) AS ventas_totales,
    AVG(f.precio_unitario) AS precio_promedio
FROM fact_ventas_detalle f
         JOIN dim_producto p ON f.producto_key = p.producto_key
         JOIN dim_canal c ON f.canal_key = c.canal_key
         JOIN dim_tiempo t ON f.tiempo_key = t.tiempo_key
GROUP BY p.categoria, p.nombre_producto, p.origen_sistema,
         c.tipo_canal, t.anio, t.mes, t.temporada;


-- Vista: perfil demográfico (solo fuentes con datos de cliente)
CREATE OR REPLACE VIEW dwh.v_perfil_demografico AS
SELECT
    cl.genero,
    cl.edad,
    CASE
        WHEN cl.edad < 25 THEN '18-24'
        WHEN cl.edad < 35 THEN '25-34'
        WHEN cl.edad < 45 THEN '35-44'
        WHEN cl.edad < 55 THEN '45-54'
        WHEN cl.edad >= 55 THEN '55+'
        ELSE 'No informado'
        END                             AS rango_etario,
    cl.origen_sistema,
    p.categoria,
    mp.tipo_pago_normalizado,
    COUNT(*)                        AS transacciones,
    SUM(f.monto_total)              AS ventas_totales,
    AVG(f.monto_total)              AS ticket_promedio,
    AVG(f.descuento_pct)            AS descuento_promedio
FROM fact_ventas_detalle f
         JOIN dim_cliente     cl ON f.cliente_key    = cl.cliente_key
         JOIN dim_producto     p ON f.producto_key   = p.producto_key
         JOIN dim_metodo_pago mp ON f.metodo_pago_key = mp.metodo_pago_key
WHERE cl.genero IS NOT NULL
GROUP BY cl.genero, cl.edad, rango_etario, cl.origen_sistema,
         p.categoria, mp.tipo_pago_normalizado;


-- Vista: métodos de pago por canal y temporada
CREATE OR REPLACE VIEW dwh.v_metodo_pago_canal AS
SELECT
    mp.tipo_pago_normalizado,
    c.tipo_canal,
    t.temporada,
    t.anio,
    COUNT(*)                AS transacciones,
    SUM(f.monto_total)      AS monto_total,
    AVG(f.cuotas_pago)      AS cuotas_promedio
FROM fact_ventas_detalle f
         JOIN dim_metodo_pago mp ON f.metodo_pago_key = mp.metodo_pago_key
         JOIN dim_canal        c ON f.canal_key        = c.canal_key
         JOIN dim_tiempo       t ON f.tiempo_key       = t.tiempo_key
GROUP BY mp.tipo_pago_normalizado, c.tipo_canal, t.temporada, t.anio;


-- Vista: KPI resumen por origen (para comparar con SupermarketBranches en Superset)
CREATE OR REPLACE VIEW dwh.v_kpi_por_origen AS
SELECT
    o.codigo_origen,
    o.nombre_completo,
    o.tipo_canal,
    o.mercado,
    COUNT(*)                    AS total_transacciones,
    SUM(f.cantidad)             AS total_unidades,
    SUM(f.monto_total)          AS ventas_totales,
    AVG(f.monto_total)          AS ticket_promedio,
    SUM(f.ganancia_neta)        AS ganancia_total,
    MIN(t.fecha)                AS fecha_min,
    MAX(t.fecha)                AS fecha_max
FROM fact_ventas_detalle f
         JOIN dim_origen o ON f.origen_key = o.origen_key
         JOIN dim_tiempo t ON f.tiempo_key = t.tiempo_key
GROUP BY o.codigo_origen, o.nombre_completo, o.tipo_canal, o.mercado;
