"""
Dune API Data Extraction Script
Extracts cached query results from Dune Analytics via API.
Paginates through results and saves to CSV.

Usage:
    export DUNE_API_KEY=your_key_here
    python dune_extract.py
"""

import os
import csv
import time
import requests

DUNE_API_KEY = os.environ.get("DUNE_API_KEY")
BASE_URL = "https://api.dune.com/api/v1"
OUTPUT_DIR = "data/raw"

QUERIES = {
    "market_trades": 6932269,
    "market_metadata": 6932485,
}

HEADERS = {"x-dune-api-key": DUNE_API_KEY}


def fetch_results(query_id, limit=30000):
    """
    Fetch cached results from a Dune query with pagination.
    Does NOT trigger a new execution.
    """
    all_rows = []
    offset = 0
    columns = []

    print(f"\nFetching query {query_id}...")

    while True:
        params = {
            "limit": limit,
            "offset": offset,
            "allow_partial_results": "true",
        }

        resp = requests.get(
            f"{BASE_URL}/query/{query_id}/results",
            headers=HEADERS,
            params=params,
        )

        if resp.status_code == 429:
            print("  Rate limited, waiting 10s...")
            time.sleep(10)
            continue

        if resp.status_code != 200:
            print(f"  Error {resp.status_code}: {resp.text}")
            break

        data = resp.json()
        meta = data.get("result", {}).get("metadata", {})
        rows = data.get("result", {}).get("rows", [])

        if not columns:
            columns = meta.get("column_names", [])
            total = meta.get("total_row_count", "?")
            print(f"  Total rows: {total}")
            print(f"  Columns: {columns}")

        if not rows:
            break

        all_rows.extend(rows)
        offset += len(rows)
        print(f"  Fetched {len(rows)} rows (total: {len(all_rows)})")

        if len(rows) < limit:
            break

        time.sleep(0.5)

    return columns, all_rows


def save_csv(filename, columns, rows):
    """Save rows to CSV."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    path = os.path.join(OUTPUT_DIR, filename)

    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)

    print(f"  Saved to {path}")
    return path


def main():
    if not DUNE_API_KEY:
        print("Set DUNE_API_KEY: export DUNE_API_KEY=your_key_here")
        return

    for name, qid in QUERIES.items():
        print(f"\n{'='*50}")
        print(f"{name} (query {qid})")
        print(f"{'='*50}")

        columns, rows = fetch_results(qid)

        if not rows:
            print(f"  No data for {name}")
            continue

        save_csv(f"{name}.csv", columns, rows)

        datapoints = len(rows) * len(columns)
        credits = datapoints / 1000
        print(f"  Rows: {len(rows)}")
        print(f"  Columns: {len(columns)}")
        print(f"  Est. credits: ~{credits:.0f}")

    print("\nDone!")


if __name__ == "__main__":
    main()
