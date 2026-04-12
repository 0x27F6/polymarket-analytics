/*
Purpose: High-level summary statistics for each category, covering volume, 
notional volume, trade activity, unique traders, and market duration.

Provides both mean and median metrics to expose skew within categories —
a large gap between mean and median signals that a small number of markets
dominate the category (as seen most clearly in Politics).

Approach:
    - category_summary: raw aggregations using sum, avg, and approx_quantile
      for median estimates. approx_quantile is used over exact median for
      performance at scale.
    - summary_rounded: applies rounding for clean output. Separated into its
      own CTE to avoid nesting round() calls inside aggregations.

Note: avg_market_length and median_market_length use date_diff in hours between
market_start_time and market_end_time. Markets with null timestamps are included
but will produce null duration values rather than being excluded.

Grain: one row per category
*/

with ranked as (
    select
        unique_key,
        question,
        category,
        total_volume_usdc,
        row_number() over (order by total_volume_usdc desc) as volume_rank,
        count(*) over () as total_markets,
        sum(total_volume_usdc) over () as total_volume
    from {{ ref('int_markets_categorized') }}
),

cumulative as (
    select
        *,
        sum(total_volume_usdc) over (order by volume_rank) as cumulative_volume,
        round(volume_rank * 100.0 / total_markets, 4) as market_pct,
        round(sum(total_volume_usdc) over (order by volume_rank) * 100.0 / total_volume, 4) as cumulative_vol_pct
    from ranked
)

select * from cumulative
order by volume_rank
