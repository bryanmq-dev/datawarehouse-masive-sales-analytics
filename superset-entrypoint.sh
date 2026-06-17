#!/bin/bash
set -e

echo ">>> superset db upgrade..."
/app/.venv/bin/superset db upgrade

echo ">>> Creando usuario admin..."
/app/.venv/bin/superset fab create-admin \
    --username admin \
    --firstname Admin \
    --lastname Admin \
    --email admin@admin.com \
    --password admin || echo "Usuario admin ya existe, continuando..."

echo ">>> superset init (roles y permisos)..."
/app/.venv/bin/superset init

echo ">>> Iniciando servidor Superset..."
exec /app/.venv/bin/gunicorn \
    --bind "0.0.0.0:8088" \
    --access-logfile - \
    --error-logfile - \
    --workers 1 \
    --worker-class gthread \
    --threads 20 \
    --timeout 120 \
    --limit-request-line 0 \
    --limit-request-field_size 0 \
    "superset.app:create_app()"
