#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== ProyectoFinal DWH — Setup ==="

# Crear directorios necesarios (postgres_data lo inicializa Docker internamente)
mkdir -p data/postgres_data data/backups superset/home

# Permisos para que el container Superset (uid 1000) pueda escribir superset.db
chmod -R 777 superset/home 2>/dev/null || true

# Build imagen custom Superset (psycopg2 + entrypoint de init)
echo ""
echo ">>> Build Superset (psycopg2 + init automático)..."
docker-compose build superset

# Levantar todos los servicios
echo ""
echo ">>> Iniciando contenedores..."
docker-compose up -d

# Esperar a que DWH esté listo (healthcheck)
echo ""
echo ">>> Esperando DWH PostgreSQL..."
until docker exec dwh_postgres pg_isready -U brayan_admin -d dwh_ventas_global 2>/dev/null; do
    printf '.'
    sleep 2
done
echo " DWH listo."

# Restaurar backup DWH si existe (busca en carpeta del proyecto o en HOME)
BACKUP_FILE=""
if [ -f "$SCRIPT_DIR/dwh_backup.sql" ]; then
    BACKUP_FILE="$SCRIPT_DIR/dwh_backup.sql"
elif [ -f "$HOME/dwh_backup.sql" ]; then
    BACKUP_FILE="$HOME/dwh_backup.sql"
fi

if [ -n "$BACKUP_FILE" ]; then
    # Verificar si el DWH ya tiene datos para no restaurar dos veces
    FACT_COUNT=$(docker exec dwh_postgres psql -U brayan_admin dwh_ventas_global -tAc \
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='dwh' AND table_name='fact_ventas_detalle';" 2>/dev/null || echo "0")

    if [ "$FACT_COUNT" = "1" ]; then
        ROWS=$(docker exec dwh_postgres psql -U brayan_admin dwh_ventas_global -tAc \
            "SELECT COUNT(*) FROM dwh.fact_ventas_detalle;" 2>/dev/null || echo "0")
    else
        ROWS="0"
    fi

    if [ "$ROWS" -gt "0" ] 2>/dev/null; then
        echo ""
        echo ">>> DWH ya tiene $ROWS registros — omitiendo restauración."
        echo "    Para forzar restauración: docker exec dwh_postgres psql -U brayan_admin dwh_ventas_global -c 'DROP SCHEMA dwh CASCADE; CREATE SCHEMA dwh;'"
        echo "    Luego: docker exec -i dwh_postgres psql -U brayan_admin dwh_ventas_global < $BACKUP_FILE"
    else
        echo ""
        echo ">>> Restaurando DWH desde $BACKUP_FILE..."
        docker exec -i dwh_postgres psql -U brayan_admin dwh_ventas_global < "$BACKUP_FILE"
        echo "Restauración completada."
    fi
else
    echo ""
    echo ">>> dwh_backup.sql no encontrado."
    echo "    Coloca en $SCRIPT_DIR/dwh_backup.sql o en ~/dwh_backup.sql y re-ejecuta install.sh"
    echo "    O ejecuta el ETL manualmente: dbt run --select marts"
fi

echo ""
echo "============================================"
echo " Superset:        http://localhost:8088"
echo " Usuario:         admin"
echo " Password:        admin"
echo " DWH PostgreSQL:  localhost:5434"
echo "============================================"
echo " Superset tarda ~60s en el primer arranque"
echo " (ejecuta db upgrade + init de roles automáticamente)"
echo "============================================"
