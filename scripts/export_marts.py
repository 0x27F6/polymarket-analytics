import duckdb
import os

DUCKDB_PATH = '../polymarket_analytics/dev.duckdb'
EXPORTS_DIR = '../polymarket_analytics/exports'

os.makedirs(EXPORTS_DIR, exist_ok=True)

con = duckdb.connect(DUCKDB_PATH, read_only=True)

# Get all tables that start with 'mart_'
tables = con.execute("""
    select table_name 
    from information_schema.tables 
    where table_schema = 'main'
    and table_name like 'mart_%'
    order by table_name
""").fetchall()

for (table,) in tables:
    out_path = os.path.join(EXPORTS_DIR, f'{table}.csv')
    con.execute(f"COPY {table} TO '{out_path}' (HEADER, DELIMITER ',')")
    print(f"Exported {table}")

con.close()
print(f"\nDone. {len(tables)} marts exported to {EXPORTS_DIR}")