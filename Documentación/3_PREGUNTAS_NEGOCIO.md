# Requerimientos de Información — Preguntas de Negocio (Sección 3.3)

## Contexto del Análisis

El proyecto integra orígenes de datos de distinto nivel de granularidad y distintos mercados del sector ventas/manufactura. El análisis va de lo granular (transacciones individuales) hacia lo agregado (comparación con resúmenes de cadenas grandes), permitiendo validar si los patrones emergentes a nivel micro son consistentes con los patrones reportados a nivel macro.

Las preguntas de negocio están organizadas por datamart origen y por el DWH consolidado.

---

## Preguntas por Datamart

### Datamart 1 — Manufactura Multinacional (WorldWideImporters)

**P1. ¿Cuáles son los productos con mayor volumen de ventas por región geográfica?**

> Permite identificar si el mix de productos varía según mercado local o si los bestsellers son globalmente consistentes. Relevante para decisiones de stock y distribución multinacional.

**P2. ¿Cómo evoluciona el ticket promedio por cliente a lo largo del tiempo?**

> Identifica si la relación comercial madura (clientes recurrentes compran más) o si hay deterioro. Métrica clave para CRM de empresas B2B.

**P3. ¿Existen diferencias estacionales en el volumen de pedidos por línea de producto?**

> La manufactura tiene ciclos de demanda estacional. Detectarlos permite planificación de producción y anticipación de cuellos de botella en cadena de suministro.

---

### Datamart 2 — E-Commerce Online (Brazilian Olist)

**P4. ¿Cuál es el método de pago predominante y cómo impacta en el ticket promedio?**

> En e-commerce latinoamericano el fraccionamiento de pago (cuotas) es masivo. Cuantificar su peso permite ajustar estrategia de precios y gestión de flujo de caja.

**P5. ¿Qué categorías de producto generan mayor ingreso en el canal online vs. el canal offline (retail)?**

> Pregunta cross-datamart. Responde si ciertos productos migran naturalmente al canal digital o si el offline retiene segmentos específicos. Insumo directo para estrategia omnicanal.

**P6. ¿Cuánto tiempo transcurre entre el pedido y la entrega, y cómo afecta esto a la recompra?**

> El lead time de entrega en e-commerce latinoamericano es un factor diferenciador crítico. Correlacionar tiempo de entrega con tasa de recompra determina el umbral de satisfacción logística.

---

### Datamart 3 — Retail Pequeño Combinado (DifferentStoreSales + RetailStoreSales)

**P7. ¿Qué temporadas del año concentran el mayor volumen de ventas en tiendas pequeñas?**

> Ambas fuentes SQLite incluyen datos de temporada. Identificar picos estacionales permite comparar si las tiendas pequeñas siguen los mismos ciclos que las cadenas grandes.

**P8. ¿Existe correlación entre el método de pago utilizado y el monto de la compra en retail pequeño?**

> En comercio pequeño, efectivo vs. tarjeta puede indicar segmento de cliente (informal vs. bancarizado). Esta correlación informa sobre perfil del consumidor local.

**P9. ¿Cómo varía el perfil demográfico del cliente (edad, sexo) según categoría de producto comprada?**

> Pregunta de segmentación. Permite construir perfiles de consumidor diferenciados y comparar si los mismos segmentos aparecen en los datos de e-commerce (Olist) o en manufactura (WWI).

---

### Integración NoSQL — Comportamiento del Consumidor (MongoDB Analytics)

**P10. ¿Qué patrones de frecuencia de compra se identifican a nivel de consumidor individual?**

> MongoDB almacena datos de comportamiento resumidos por cliente. Permite identificar consumidores de alta frecuencia, estacionales u ocasionales. Complementa la visión transaccional clásica con una visión centrada en el cliente.

**P11. ¿Los patrones de tendencia de ventas en el modelo NoSQL son consistentes con los registros transaccionales relacionales?**

> Si MongoDB (resúmenes de comportamiento) y los orígenes OLTP (transacciones individuales) muestran las mismas tendencias, se confirma la coherencia del pipeline de integración NoSQL→relacional. Si divergen, revela qué información se pierde en la agregación.

---

## Preguntas del DWH Consolidado

**P12. ¿Los KPIs diarios del DWH (ventas agregadas por canal y fecha) son consistentes con los reportes de resumen de SupermarketStoreBranchesSales (896 sucursales)?**

> Esta es la pregunta analítica central del proyecto. Compara dos mundos: el DWH construido desde datos granulares vs. una fuente que ya entrega resúmenes operacionales de una cadena grande. Si los indicadores convergen, valida la metodología. Si divergen, revela diferencias estructurales entre mercados o entre metodologías de reporte.

**P13. ¿Qué canal de venta (online/e-commerce vs. offline/retail) genera mayor ticket promedio por transacción, controlando por región y temporada?**

> Pregunta cross-origen. Usa Olist (online) vs. DiffStore+Retail (offline) con WWI como referente B2B. Responde la pregunta de estrategia omnicanal con datos de tres mercados distintos simultáneamente.

**P14. ¿Existen diferencias en el comportamiento de ventas entre el mercado latinoamericano (Olist, Brasil) y el mercado multinacional (WWI)?**

> Pregunta de inteligencia de mercado. Controla por categorías similares de producto y compara ticket promedio, frecuencia de compra y estacionalidad entre mercados. Relevante para empresas que operan en múltiples geografías.

**P15. ¿Cuál es la distribución del ingreso por sucursal en cadenas grandes (SupermarketBranches) comparada con el ingreso total agregado de tiendas pequeñas del DWH?**

> Pregunta de escala y concentración. ¿Cuántas tiendas pequeñas equivalen a una sucursal de cadena grande en términos de volumen? Responde sobre viabilidad competitiva del retail independiente frente a grandes cadenas.

---

## Justificaciones del Proyecto

### Justificación del enfoque granular→agregado

El análisis parte de transacciones individuales (máxima granularidad) y construye agregaciones progresivas hasta llegar a KPIs diarios por canal. Esto permite auditar cada nivel de agregación y detectar pérdidas de información o inconsistencias que en un sistema puramente pre-agregado serían invisibles.

### Justificación de múltiples orígenes heterogéneos

Ninguna organización real opera con un único sistema transaccional. La capacidad de integrar datos de PostgreSQL, SQL Server, SQLite y MongoDB en un único DWH refleja el escenario empresarial estándar donde el historial de TI acumula tecnologías diversas. El proyecto demuestra que un DWH bien diseñado es agnóstico al motor de origen.

### Justificación de MongoDB en un contexto relacional

Las organizaciones de gran escala (redes sociales, SaaS, IaaS, PaaS) adoptan bases de datos NoSQL por su eficiencia en escritura masiva y esquemas flexibles. Sin embargo, los sistemas de inteligencia de negocios exigen consistencia y estructura relacional. La integración MongoDB→CSV→FDW→DWH demuestra el pipeline de conversión que toda empresa con arquitectura híbrida necesita implementar.

### Justificación de dbt como motor ETL

dbt (data build tool) es el estándar empresarial para transformaciones en DWH modernos según rankings de adopción en el sector (State of Data Engineering 2023-2024). A diferencia de SSIS, opera directamente en SQL, genera linaje de datos automático, permite pruebas declarativas sobre los modelos y produce documentación del pipeline como artefacto nativo. Para un volumen de ~2 millones de registros con múltiples orígenes heterogéneos, dbt ofrece rendimiento y mantenibilidad superiores.

### Justificación de Apache Superset como herramienta de visualización

Apache Superset es la herramienta de BI open-source más adoptada en entornos corporativos de alto volumen (Airbnb, Twitter, Lyft la usan en producción). A diferencia de Power BI Desktop, no impone límite de filas en el modelo de datos y se conecta directamente a PostgreSQL sin capas intermedias. Para un DWH con ~2 millones de registros, esta conexión directa elimina el cuello de botella de importación de datos que Power BI presenta en su versión gratuita.

### Justificación de SupermarketBranches como fuente de contraste externa

SupermarketStoreBranchesSales no se integra al DWH porque su granularidad (resumen diario por sucursal) es incompatible con el nivel transaccional del modelo dimensional diseñado. Su rol es el de benchmark: permite contrastar si los patrones emergentes del DWH granular son coherentes con los reportes operacionales de una cadena con 896 sucursales. Esta comparación tiene valor analítico sin requerir integración al modelo.
