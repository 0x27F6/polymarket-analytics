## How to Reproduce

### Prerequisites

- Python 3.11
- A Dune Analytics account with API access
- Git

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/0x27F6/polymarket-analytics
cd polymarket-analytics
```

**2. Create and activate a virtual environment**
```bash
python3.11 -m venv venv
source venv/bin/activate
```

**3. Install dependencies**
```bash
pip install dbt-duckdb pandas matplotlib requests
```

**4. Set your Dune API key**
```bash
export DUNE_API_KEY=your_key_here
```

### Extract Data from Dune

Run the extraction script to pull raw trade and metadata from Dune Analytics.
This fetches cached query results and writes them to `data/raw/`.
```bash
python scripts/dune_extract.py
```

This will extract two datasets:
- `market_trades.csv` — taker-sided trade events (query 6932269)
- `market_metadata.csv` — market metadata including tags and timestamps (query 6932485)

> **Note:** The Dune queries use cached results and do not trigger new executions.
> Results reflect the state of the data at the time of the last query run.

### Test the dbpt Pipeline
Ensure packages.yml is downloaded in the root of polymarket and contains:
```bash

packages:
  - package: dbt-labs/dbt_utils
    version: 1.1.1
```

install dependencies:  

```bash

dbt deps 
```

run: 

```bash

dbt test

```
> ### Notes on Data Quality
>The stg_market_metadata model contains:
>	•	3,506 null values in market_end_time
>	•	2,369 null values in market_start_time

>These nulls are expected due to incomplete or unresolved market metadata in the
> upstream dataset.

>They are handled downstream via COALESCE where required for analysis and are not
> considered data quality violations in this pipeline. 

### Run the dbt Pipeline
```bash
cd polymarket_dbt
dbt run
```

This builds all models in order — staging → intermediate → marts — and writes
results to a local DuckDB file.

### Export Marts to CSV
```bash
python scripts/export_marts.py
```

This writes all mart tables to `exports/` as CSVs for use in visualization scripts.

### Generate Charts

Each chart has a corresponding script in `scripts/`:
```bash
python scripts/power_law_chart.py
python scripts/market_creation_chart.py
python scripts/volume_by_category_chart.py
python scripts/volume_skew_chart.py
python scripts/lorenz_curve.py
```

Charts are saved to `assets/charts/`.

### dbt Profile Setup

Your `~/.dbt/profiles.yml` should contain:
```yaml
polymarket_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: /path/to/polymarket_analytics/dev.duckdb
```
