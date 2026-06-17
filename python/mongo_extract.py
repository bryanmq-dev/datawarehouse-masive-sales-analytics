"""
MongoDB Analytics → CSV Extractor
Fuente: MongoDBAnalytics/ (JSON files o conexión Atlas)
Destino: /mnt/mongo_exports/ (CSVs para FDW o COPY en PostgreSQL)

Colecciones:
  - transactions: buckets de transacciones financieras (buy/sell de acciones)
  - customers: clientes financieros con tier (Bronze/Silver/Gold)
  - accounts: cuentas con productos financieros

Rol en DWH: fuente comparativa externa (no integrada al modelo dimensional)
Análisis: correlación actividad financiera vs picos de ventas retail
"""

import json
import csv
import os
from datetime import datetime, timezone
from pathlib import Path


# ─── CONFIGURACIÓN ────────────────────────────────────────────

# Modo lectura: 'files' para JSONs locales | 'atlas' para conexión MongoDB
READ_MODE = os.getenv("MONGO_MODE", "files")

# Rutas de archivos locales
BASE_DIR   = Path(__file__).parent.parent
INPUT_DIR  = BASE_DIR / "MongoDBAnalytics"
OUTPUT_DIR = Path(os.getenv("MONGO_OUTPUT_DIR", "/mnt/mongo_exports"))

# Conexión Atlas (solo si READ_MODE = 'atlas')
MONGO_URI  = os.getenv("MONGO_URI", "mongodb://localhost:27017")
MONGO_DB   = os.getenv("MONGO_DB",  "sample_analytics")


# ─── UTILIDADES ───────────────────────────────────────────────

def parse_mongo_date(value) -> str | None:
    """Convierte Extended JSON date a string ISO."""
    if value is None:
        return None
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        # Extended JSON: {"$date": {"$numberLong": "1063065600000"}}
        if "$date" in value:
            d = value["$date"]
            if isinstance(d, dict) and "$numberLong" in d:
                ts_ms = int(d["$numberLong"])
                return datetime.fromtimestamp(ts_ms / 1000, tz=timezone.utc).strftime("%Y-%m-%d")
            if isinstance(d, str):
                return d[:10]
    return str(value)


def parse_mongo_number(value) -> float | None:
    """Convierte Extended JSON number a float."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, dict):
        for key in ("$numberInt", "$numberLong", "$numberDouble", "$numberDecimal"):
            if key in value:
                return float(value[key])
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def parse_mongo_id(value) -> str | None:
    """Convierte ObjectId, $numberInt/$numberLong o int a string."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return str(int(value))
    if isinstance(value, dict):
        if "$oid" in value:
            return value["$oid"]
        for key in ("$numberInt", "$numberLong", "$numberDouble"):
            if key in value:
                return str(value[key])
    return str(value)


def load_jsonl(filepath: Path):
    """Lee archivo JSON lines (un documento por línea)."""
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                yield json.loads(line)


# ─── EXTRACTOR: TRANSACTIONS ──────────────────────────────────

def extract_transactions_files() -> list[dict]:
    """
    Aplana los buckets de transacciones.
    Cada documento tiene un array 'transactions' con múltiples operaciones.
    Grain resultante: 1 fila por operación individual.
    """
    rows = []
    filepath = INPUT_DIR / "transactions.json"

    for doc in load_jsonl(filepath):
        account_id     = parse_mongo_id(doc.get("account_id"))
        tx_count       = parse_mongo_number(doc.get("transaction_count"))
        bucket_start   = parse_mongo_date(doc.get("bucket_start_date"))
        bucket_end     = parse_mongo_date(doc.get("bucket_end_date"))

        for tx in doc.get("transactions", []):
            rows.append({
                "account_id":        account_id,
                "transaction_count": tx_count,
                "bucket_start_date": bucket_start,
                "bucket_end_date":   bucket_end,
                "tx_date":           parse_mongo_date(tx.get("date")),
                "amount":            parse_mongo_number(tx.get("amount")),
                "transaction_code":  tx.get("transaction_code"),   # buy | sell
                "symbol":            tx.get("symbol"),              # ticker bursátil
                "price":             tx.get("price"),               # precio por acción (string decimal)
                "total":             tx.get("total"),               # monto total (string decimal)
            })

    return rows


def extract_transactions_atlas(db) -> list[dict]:
    rows = []
    for doc in db.transactions.find({}):
        account_id   = str(doc.get("account_id", ""))
        tx_count     = doc.get("transaction_count", 0)
        bucket_start = doc.get("bucket_start_date")
        bucket_end   = doc.get("bucket_end_date")

        for tx in doc.get("transactions", []):
            rows.append({
                "account_id":        account_id,
                "transaction_count": tx_count,
                "bucket_start_date": bucket_start.strftime("%Y-%m-%d") if bucket_start else None,
                "bucket_end_date":   bucket_end.strftime("%Y-%m-%d")   if bucket_end   else None,
                "tx_date":           tx.get("date").strftime("%Y-%m-%d") if tx.get("date") else None,
                "amount":            float(tx.get("amount", 0)),
                "transaction_code":  tx.get("transaction_code"),
                "symbol":            tx.get("symbol"),
                "price":             str(tx.get("price", "")),
                "total":             str(tx.get("total", "")),
            })
    return rows


# ─── EXTRACTOR: CUSTOMERS ─────────────────────────────────────

def extract_customers_files() -> list[dict]:
    """
    Aplana clientes financieros.
    tier_and_details es un dict con valores de tier/beneficios — extrae el tier principal.
    """
    rows = []
    filepath = INPUT_DIR / "customers.json"

    for doc in load_jsonl(filepath):
        # Extraer tier principal de tier_and_details
        tier_and_details = doc.get("tier_and_details", {})
        primary_tier = None
        if isinstance(tier_and_details, dict):
            for v in tier_and_details.values():
                if isinstance(v, dict) and "tier" in v:
                    primary_tier = v["tier"]
                    break

        rows.append({
            "username":   doc.get("username"),
            "name":       doc.get("name"),
            "email":      doc.get("email"),
            "active":     doc.get("active"),
            "birthdate":  parse_mongo_date(doc.get("birthdate")),
            "tier":       primary_tier,                              # Bronze | Silver | Gold
            "n_accounts": len(doc.get("accounts", [])),
        })

    return rows


def extract_customers_atlas(db) -> list[dict]:
    rows = []
    for doc in db.customers.find({}):
        tier_and_details = doc.get("tier_and_details", {})
        primary_tier = None
        for v in tier_and_details.values():
            if "tier" in v:
                primary_tier = v["tier"]
                break
        rows.append({
            "username":   doc.get("username"),
            "name":       doc.get("name"),
            "email":      doc.get("email"),
            "active":     doc.get("active"),
            "birthdate":  doc.get("birthdate").strftime("%Y-%m-%d") if doc.get("birthdate") else None,
            "tier":       primary_tier,
            "n_accounts": len(doc.get("accounts", [])),
        })
    return rows


# ─── EXTRACTOR: ACCOUNTS ──────────────────────────────────────

def extract_accounts_files() -> list[dict]:
    """Aplana cuentas financieras. 'products' es array de strings."""
    rows = []
    filepath = INPUT_DIR / "accounts.json"

    for doc in load_jsonl(filepath):
        products = doc.get("products", [])
        rows.append({
            "account_id":    parse_mongo_id(doc.get("account_id")),
            "limit":         parse_mongo_number(doc.get("limit")),
            "products":      "|".join(products) if products else None,  # pipe-separated
            "n_products":    len(products),
        })

    return rows


def extract_accounts_atlas(db) -> list[dict]:
    rows = []
    for doc in db.accounts.find({}):
        products = doc.get("products", [])
        rows.append({
            "account_id":  str(doc.get("account_id", "")),
            "limit":       float(doc.get("limit", 0)),
            "products":    "|".join(products) if products else None,
            "n_products":  len(products),
        })
    return rows


# ─── ESCRITURA CSV ────────────────────────────────────────────

def write_csv(rows: list[dict], output_path: Path, description: str) -> None:
    if not rows:
        print(f"[WARN] {description}: sin registros — CSV no generado")
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = list(rows[0].keys())

    with open(output_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print(f"[OK] {description}: {len(rows):,} filas → {output_path}")


# ─── MAIN ─────────────────────────────────────────────────────

def main():
    print(f"Modo: {READ_MODE}")
    print(f"Output: {OUTPUT_DIR}")
    print()

    if READ_MODE == "atlas":
        try:
            from pymongo import MongoClient
        except ImportError:
            raise SystemExit("pymongo no instalado. Ejecuta: pip install pymongo")

        client = MongoClient(MONGO_URI)
        db = client[MONGO_DB]

        tx_rows      = extract_transactions_atlas(db)
        cust_rows    = extract_customers_atlas(db)
        account_rows = extract_accounts_atlas(db)
        client.close()

    else:
        # Modo local: leer JSONs de MongoDBAnalytics/
        if not INPUT_DIR.exists():
            raise SystemExit(f"Directorio no encontrado: {INPUT_DIR}")

        tx_rows      = extract_transactions_files()
        cust_rows    = extract_customers_files()
        account_rows = extract_accounts_files()

    write_csv(tx_rows,      OUTPUT_DIR / "transactions_flat.csv",
              "Transacciones financieras (aplanadas)")
    write_csv(cust_rows,    OUTPUT_DIR / "customers_flat.csv",
              "Clientes financieros")
    write_csv(account_rows, OUTPUT_DIR / "accounts_flat.csv",
              "Cuentas financieras")

    print()
    print("Carga en PostgreSQL (COPY):")
    print(f"  COPY mongo_transacciones FROM '{OUTPUT_DIR}/transactions_flat.csv' CSV HEADER;")
    print(f"  COPY mongo_clientes      FROM '{OUTPUT_DIR}/customers_flat.csv'    CSV HEADER;")
    print(f"  COPY mongo_cuentas       FROM '{OUTPUT_DIR}/accounts_flat.csv'     CSV HEADER;")


if __name__ == "__main__":
    main()
