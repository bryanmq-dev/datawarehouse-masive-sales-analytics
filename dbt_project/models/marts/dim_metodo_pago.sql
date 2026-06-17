{{ config(materialized='table') }}

SELECT
    ROW_NUMBER() OVER (ORDER BY origen_sistema, tipo_pago_origen) AS metodo_pago_key,
    tipo_pago_normalizado,
    tipo_pago_origen,
    acepta_cuotas,
    origen_sistema
FROM (VALUES
    ('Efectivo',         'Cash',         FALSE, 'DIFFSTORE'),
    ('Tarjeta Crédito',  'Credit Card',  FALSE, 'DIFFSTORE'),
    ('Tarjeta Débito',   'Debit Card',   FALSE, 'DIFFSTORE'),
    ('Tarjeta Crédito',  'credit_card',  TRUE,  'OLIST'),
    ('Boleto',           'boleto',       FALSE, 'OLIST'),
    ('Voucher',          'voucher',      FALSE, 'OLIST'),
    ('Tarjeta Débito',   'debit_card',   FALSE, 'OLIST'),
    ('Efectivo',         'Cash',         FALSE, 'RETAIL'),
    ('Tarjeta Crédito',  'Credit Card',  FALSE, 'RETAIL'),
    ('Tarjeta Débito',   'Debit Card',   FALSE, 'RETAIL'),
    ('Otro',             'Card',         FALSE, 'RETAIL'),
    ('Cheque',           'Check',        FALSE, 'WWI'),
    ('Efectivo',         'Cash',         FALSE, 'WWI'),
    ('No informado',     'NULL',         FALSE, 'WWI'),
    ('Tarjeta Crédito',  'Credit Card',  FALSE, 'WWI'),
    ('Transferencia',    'EFT',          FALSE, 'WWI')
) AS t(tipo_pago_normalizado, tipo_pago_origen, acepta_cuotas, origen_sistema)
