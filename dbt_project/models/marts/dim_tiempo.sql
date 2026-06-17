{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY d)          AS tiempo_key,
    d::DATE                                 AS fecha,
    EXTRACT(DAY     FROM d)::SMALLINT       AS dia,
    EXTRACT(WEEK    FROM d)::SMALLINT       AS semana,
    EXTRACT(MONTH   FROM d)::SMALLINT       AS mes,
    EXTRACT(QUARTER FROM d)::SMALLINT       AS trimestre,
    EXTRACT(YEAR    FROM d)::SMALLINT       AS anio,
    TO_CHAR(d, 'TMDay')                     AS nombre_dia,
    TO_CHAR(d, 'TMMonth')                   AS nombre_mes,
    CASE
        WHEN EXTRACT(MONTH FROM d) IN (3,4,5)    THEN 'Primavera'
        WHEN EXTRACT(MONTH FROM d) IN (6,7,8)    THEN 'Verano'
        WHEN EXTRACT(MONTH FROM d) IN (9,10,11)  THEN 'Otoño'
        ELSE 'Invierno'
    END                                     AS temporada,
    (EXTRACT(ISODOW FROM d) >= 6)           AS es_fin_semana
FROM generate_series(
    '2013-01-01'::DATE,
    '2018-12-31'::DATE,
    '1 day'::INTERVAL
) d
