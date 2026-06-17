# Metodología HEFESTO — Aplicación Top-Down

## Paso 1: Preguntas de Negocio (ver 3_PREGUNTAS_NEGOCIO.md)

Las 15 preguntas definidas guían todo el diseño descendente. El modelo se construye para responderlas, no al revés.

---

## Paso 2: Indicadores y Perspectivas

### Indicadores derivados de las preguntas

| Indicador                         | Pregunta origen      | Tipo                           |
| --------------------------------- | -------------------- | ------------------------------ |
| Total ventas (monto)              | P1, P4, P5, P12, P13 | Medida aditiva                 |
| Ticket promedio por transacción   | P2, P4, P13          | Medida semi-aditiva            |
| Volumen de unidades vendidas      | P1, P7               | Medida aditiva                 |
| Margen de ganancia bruta          | P2                   | Medida aditiva                 |
| Participación por canal (%)       | P5, P13              | Medida calculada               |
| Distribución de métodos de pago   | P4, P8               | Medida calculada               |
| Variación estacional (MoM %)      | P3, P7               | Medida calculada               |
| Frecuencia de compra por cliente  | P10                  | Medida semi-aditiva            |
| Tiempo de entrega en días         | P6                   | Medida aditiva                 |
| Cuotas promedio por pago          | P4                   | Medida semi-aditiva            |
| Compras previas del cliente       | P9                   | Medida semi-aditiva            |
| Delta KPI DWH vs Supermarket      | P12                  | Medida calculada (comparación) |
| Volumen transacciones financieras | Comparativo MongoDB  | Medida aditiva externa         |

### Perspectivas (Dimensiones) derivadas

| Perspectiva    | Fuentes                            | Rol                               |
| -------------- | ---------------------------------- | --------------------------------- |
| Tiempo         | Todas                              | Análisis temporal, estacionalidad |
| Producto       | WWI, Olist, RetailStore, DiffStore | Qué se vende                      |
| Cliente        | WWI, Olist, RetailStore, DiffStore | Quién compra                      |
| Región         | WWI, Olist, DiffStore              | Dónde se vende                    |
| Método de Pago | WWI, Olist, RetailStore, DiffStore | Cómo se paga                      |
| Canal          | Derivada de origen                 | Online vs Offline vs B2B          |
| Tienda         | DiffStore (shopping_mall)          | En qué punto de venta             |
| Origen Sistema | Todos                              | Trazabilidad cross-fuente         |

---

## Paso 3: Modelo Conceptual Multidimensional

### Tabla de Hechos Central

**FactVentasDetalle** — granularidad: 1 fila por línea de venta individual

```
FactVentasDetalle
├── tiempo_key         → DimTiempo
├── producto_key       → DimProducto
├── cliente_key        → DimCliente
├── region_key         → DimRegion
├── metodo_pago_key    → DimMetodoPago
├── canal_key          → DimCanal
├── tienda_key         → DimTienda (nullable)
├── origen_key         → DimOrigen
└── MEDIDAS:
    ├── cantidad
    ├── precio_unitario
    ├── monto_total
    ├── costo_unitario          (solo DiffStore)
    ├── ganancia_neta           (WWI, DiffStore)
    ├── descuento_pct           (solo RetailStore)
    ├── calificacion_item       (solo RetailStore)
    ├── tiempo_entrega_dias     (solo Olist)
    ├── cuotas_pago             (solo Olist)
    └── compras_previas         (solo RetailStore)
```

### Fuentes Comparativas Externas (no integradas al modelo dimensional)

```
SupermarketStoreBranchesSales  → consulta FDW directa en Superset
MongoDB Analytics (CSV)        → consulta FDW file directa en Superset
```

Estas fuentes se consultan en la capa de visualización para contraste con los KPIs agregados de FactVentasDetalle. No tienen dimensiones propias en el DWH.

---

## Paso 4: Mapeo Columnas Origen → DWH

### DimTiempo (generada, sin fuente directa)

Poblada con rango de fechas que cubre todos los orígenes (2013–2018 para WWI, 2016–2018 para DiffStore, 2017–2018 para Olist, sin fecha explícita para RetailStore → usar fecha de carga).

| Campo DWH     | Cálculo                                                                                                                           |
| ------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| fecha         | fecha base                                                                                                                        |
| dia           | EXTRACT(DAY FROM fecha)                                                                                                           |
| semana        | EXTRACT(WEEK FROM fecha)                                                                                                          |
| mes           | EXTRACT(MONTH FROM fecha)                                                                                                         |
| trimestre     | EXTRACT(QUARTER FROM fecha)                                                                                                       |
| anio          | EXTRACT(YEAR FROM fecha)                                                                                                          |
| nombre_dia    | TO_CHAR(fecha, 'Day')                                                                                                             |
| nombre_mes    | TO_CHAR(fecha, 'Month')                                                                                                           |
| temporada     | CASE WHEN mes IN (12,1,2) THEN 'Invierno' WHEN mes IN (3,4,5) THEN 'Primavera' WHEN mes IN (6,7,8) THEN 'Verano' ELSE 'Otoño' END |
| es_fin_semana | EXTRACT(ISODOW FROM fecha) >= 6                                                                                                   |

### DimProducto — mapeo por origen

| Campo DWH          | WWI                                                    | Olist                         | RetailStore                       | DiffStore   |
| ------------------ | ------------------------------------------------------ | ----------------------------- | --------------------------------- | ----------- |
| producto_id_origen | StockItemID                                            | product_id                    | Category\|\|'\|'\|\|ItemPurchased | category    |
| nombre_producto    | StockItemName                                          | product_category_name_english | ItemPurchased                     | category    |
| categoria          | StockGroupName (join StockItemStockGroups→StockGroups) | product_category_name_english | Category                          | category    |
| subcategoria       | NULL                                                   | NULL                          | ItemPurchased                     | NULL        |
| origen_sistema     | 'WWI'                                                  | 'OLIST'                       | 'RETAIL'                          | 'DIFFSTORE' |

### DimCliente — mapeo por origen

| Campo DWH         | WWI                             | Olist              | RetailStore | DiffStore   |
| ----------------- | ------------------------------- | ------------------ | ----------- | ----------- |
| cliente_id_origen | CustomerID                      | customer_unique_id | CustomerID  | customer_id |
| nombre_cliente    | CustomerName                    | NULL               | NULL        | NULL        |
| edad              | NULL                            | NULL               | Age         | age         |
| genero            | NULL                            | NULL               | Gender      | gender      |
| ciudad            | CityName (join Cities)          | customer_city      | NULL        | NULL        |
| estado_provincia  | StateProvinceName (join States) | customer_state     | NULL        | state       |
| pais              | CountryName (join Countries)    | 'Brasil'           | NULL        | NULL        |
| region_geografica | SalesTerritory                  | NULL               | NULL        | region      |
| origen_sistema    | 'WWI'                           | 'OLIST'            | 'RETAIL'    | 'DIFFSTORE' |

### DimMetodoPago — mapeo por origen

| Campo DWH             | WWI               | Olist                      | RetailStore   | DiffStore      |
| --------------------- | ----------------- | -------------------------- | ------------- | -------------- |
| tipo_pago_normalizado | PaymentMethodName | payment_type normalizado\* | PaymentMethod | payment_method |
| cuotas                | NULL              | payment_installments       | NULL          | NULL           |

\*Normalización Olist: `credit_card→'Tarjeta Crédito'`, `boleto→'Boleto'`, `voucher→'Voucher'`, `debit_card→'Tarjeta Débito'`

### DimCanal — derivada por origen

| origen_sistema | tipo_canal | subcategoria             |
| -------------- | ---------- | ------------------------ |
| WWI            | B2B        | Manufactura/Distribución |
| OLIST          | Online     | E-Commerce               |
| RETAIL         | Offline    | Tienda Retail            |
| DIFFSTORE      | Offline    | Centro Comercial         |

### DimTienda — solo DiffStore

| Campo DWH        | DiffStore     |
| ---------------- | ------------- |
| tienda_id_origen | shopping_mall |
| nombre_mall      | shopping_mall |
| ciudad           | NULL          |
| estado           | state         |
| region           | region        |

### FactVentasDetalle — mapeo de medidas

| Medida DWH          | WWI                        | Olist                         | RetailStore        | DiffStore                                |
| ------------------- | -------------------------- | ----------------------------- | ------------------ | ---------------------------------------- |
| cantidad            | Quantity                   | 1 (por item)                  | 1                  | quantity                                 |
| precio_unitario     | UnitPrice                  | price                         | Amount             | selling_price_per_unit                   |
| monto_total         | ExtendedPrice              | price + freight_value         | Amount             | quantity \* selling_price_per_unit       |
| costo_unitario      | NULL                       | NULL                          | NULL               | cost_price_per_unit                      |
| ganancia_neta       | LineProfit                 | NULL                          | NULL               | (selling_price - cost_price) \* quantity |
| descuento_pct       | StandardDiscountPercentage | NULL                          | DiscountApplied(%) | NULL                                     |
| calificacion_item   | NULL                       | review_score (join)           | ItemRating         | NULL                                     |
| tiempo_entrega_dias | NULL                       | DATEDIFF(delivered, purchase) | NULL               | NULL                                     |
| cuotas_pago         | NULL                       | payment_installments          | NULL               | NULL                                     |
| compras_previas     | NULL                       | NULL                          | PreviousPurchases  | NULL                                     |

---

## Paso 5: Modelo Lógico

Ver `sql/dwh_01_dimensiones.sql` y `sql/dwh_02_hechos.sql`.

Tipo de modelo: **Esquema Estrella** (Star Schema).  
Justificación: mayor rendimiento en consultas analíticas, menor complejidad de JOINs, estándar Kimball para DWH orientado a reporting.

---
