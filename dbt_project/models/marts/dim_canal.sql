{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY tipo_canal, subcategoria_canal) AS canal_key,
    tipo_canal,
    subcategoria_canal,
    descripcion
FROM (VALUES
    ('B2B',     'Manufactura-Distribución', 'Ventas mayoristas multinacionales — WorldWideImporters'),
    ('Offline', 'Centro Comercial',         'Ventas presenciales en mall — DifferentStoreSales'),
    ('Offline', 'Tienda Retail',            'Ventas presenciales en tienda — RetailStoreSales'),
    ('Online',  'E-Commerce',               'Ventas por plataforma digital — Brazilian Olist')
) AS t(tipo_canal, subcategoria_canal, descripcion)
