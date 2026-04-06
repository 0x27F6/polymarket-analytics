import duckdb
import os

os.makedirs('/Users/indi/workspace/polymarket_analytics/exports', exist_ok=True)

con = duckdb.connect('/Users/indi/workspace/polymarket_analytics/dev.duckdb', read_only=True)

tables = [
    'mart_category_concentration',
    'mart_market_creation',
    'mart_market_duration',
    'mart_market_summary',
    'mart_power_law_volume',
    'mart_top_markets_all_time',
    'mart_top_markets_by_category'
]

for table in tables:
    con.execute(f"COPY {table} TO '/Users/indi/workspace/polymarket_analytics/exports/{table}.csv' (HEADER, DELIMITER ',')")
    print(f"Exported {table}")

con.close()