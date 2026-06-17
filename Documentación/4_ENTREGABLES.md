# Entregables del Proyecto

## Repositorio GitHub

Repositorio público con todos los artefactos del proyecto organizados por sección del informe.

### Estructura del repositorio

```
/
├── README.md                     # Guía de inicio rápido y descripción general
├── docs/                         # Documentación del proyecto
│   ├── 1_ORIGENES.md
│   ├── 2_CONEXION.md
│   ├── 3_PREGUNTAS_NEGOCIO.md
│   ├── 4_ENTREGABLES.md
│   ├── 5_HEFESTO.md
│   └── arquitectura/             # Diagramas (estrella, HEFESTO, ETL flow)
├── data/                         # Guía de descarga de orígenes de datos
│   └── DESCARGA_ORIGENES.md      # Links oficiales + instrucciones por fuente
├── infra/                        # Docker Compose y configuración de entorno
│   ├── docker-compose.yml        # PostgreSQL DWH + Superset + fuentes
│   └── init/                     # Scripts de inicialización de servidores FDW
├── sql/                          # Scripts SQL del DWH
│   ├── 01_extensiones_fdw.sql
│   ├── 02_servidores_origen.sql
│   ├── 03_esquemas_staging.sql
│   ├── 04_dimensiones.sql
│   ├── 05_hechos.sql
│   └── 06_validacion.sql
├── dbt/                          # Proyecto dbt completo
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/              # Modelos de extracción por origen
│   │   ├── intermediate/         # Transformaciones y homologación
│   │   └── marts/                # Modelos finales: dimensiones y facts
│   ├── tests/                    # Pruebas de calidad de datos
│   └── docs/                     # Linaje generado por dbt docs generate
├── python/                       # Pipeline MongoDB → CSV
│   ├── mongo_extract.py
│   └── requirements.txt
└── superset/                     # Configuración de dashboards exportados
    └── dashboards_export.zip
```

---

## Entregable 1 — Informe Final (PDF)

Informe estructurado según el formato de la asignatura, secciones 1–10 más anexos.

---

## Entregable 2 — Repositorio GitHub

Repositorio público con todo el código fuente, scripts SQL, modelos dbt, pipeline Python y documentación técnica.

Incluye:

- Scripts SQL organizados en orden de ejecución numerado
- Proyecto dbt completo con modelos, pruebas y documentación de linaje
- Docker Compose para replicar el entorno completo localmente
- Pipeline Python para extracción MongoDB

---

## Entregable 3 — Guía de Descarga de Orígenes de Datos (`data/DESCARGA_ORIGENES.md`)

Documento dentro del repositorio con:

| Origen                        | Fuente oficial                | Formato           | Instrucción                                           |
| ----------------------------- | ----------------------------- | ----------------- | ----------------------------------------------------- |
| WorldWideImporters            | Microsoft GitHub oficial      | SQL backup (.bak) | Restaurar en PostgreSQL con herramienta de conversión |
| Brazilian Olist               | Kaggle dataset público        | CSV               | Importar al esquema dwh en SQL Server                 |
| MongoDB Analytics             | MongoDB Atlas sample datasets | JSON dump         | mongorestore al cluster local                         |
| DifferentStoreSales           | Kaggle / fuente original      | SQLite (.sqlite)  | Copiar a /mnt/sqlite_data/                            |
| SupermarketStoreBranchesSales | Kaggle / fuente original      | SQLite (.sqlite)  | Copiar a /mnt/sqlite_data/                            |
| RetailStoreSales              | Kaggle / fuente original      | SQLite (.sqlite)  | Copiar a /mnt/sqlite_data/                            |

---

## Entregable 4 — Guía de Instalación y Replicación

`README.md` en la raíz del repositorio. Contenido:

1. Requisitos previos (Docker, Docker Compose, Python 3.10+)
2. Clonar repositorio
3. Descargar orígenes de datos según `data/DESCARGA_ORIGENES.md`
4. Levantar entorno: `docker-compose up -d`
5. Ejecutar scripts SQL en orden numerado
6. Ejecutar pipeline MongoDB: `python python/mongo_extract.py`
7. Ejecutar dbt: `dbt run && dbt test`
8. Acceder a Superset en `localhost:8088`

---

## Entregable 5 — Apache Superset en Producción

Instancia de Apache Superset desplegada y conectada al DWH PostgreSQL resultado, accesible en línea para evaluación directa sin instalación local.

Incluye:

- URL de acceso público
- Credenciales de lectura para el docente (usuario de solo lectura)
- Todos los dashboards del proyecto precargados y funcionales
- Conexión directa al DWH PostgreSQL con datos reales del proyecto

Permite al docente explorar los dashboards, filtrar datos y verificar los KPIs sin necesidad de instalar ningún software.

---

## Entregable 6 — Video Explicativo

Video de 15–20 minutos cubriendo:

1. Descripción general de la arquitectura (diagrama)
2. Demostración de las conexiones FDW activas (consulta en vivo)
3. Ejecución del pipeline dbt (dbt run en terminal)
4. Recorrido por los dashboards en Superset producción
5. Interpretación de los hallazgos principales por datamart
6. Comparación final DWH granular vs. SupermarketBranches

Formato: MP4, enlace en README del repositorio (YouTube unlisted o Drive).

---

## Resumen de Entregables

| #   | Entregable                | Formato     | Ubicación                           |
| --- | ------------------------- | ----------- | ----------------------------------- |
| 1   | Informe Final             | PDF         | Repositorio /docs + entrega directa |
| 2   | Código fuente completo    | GitHub repo | URL pública                         |
| 3   | Guía de orígenes de datos | MD en repo  | /data/DESCARGA_ORIGENES.md          |
| 4   | Guía de instalación       | MD en repo  | /README.md                          |
| 5   | Superset en producción    | URL pública | Credenciales en README              |
| 6   | Video explicativo         | MP4 / URL   | Enlace en README                    |
