# scripts/load_raw.py
import duckdb

con = duckdb.connect('../polymarket_analytics/dev.duckdb')

con.execute("""
    CREATE OR REPLACE TABLE raw_market_trades AS 
    SELECT * FROM read_csv('../polymarket_analytics/data/raw/market_trades.csv')
""")

con.execute("""
    CREATE OR REPLACE TABLE raw_market_metadata AS 
    SELECT * FROM read_csv('/Users/indi/workspace/polymarket_analytics/data/raw/market_metadata.csv')
""")

print("Trades:", con.execute("SELECT count(*) FROM raw_market_trades").fetchone()[0])
print("Metadata:", con.execute("SELECT count(*) FROM raw_market_metadata").fetchone()[0])

con.close()
print("Done!")