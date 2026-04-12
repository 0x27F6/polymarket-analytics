/*
/*

Purpose: Monthly market creation and volume trends by category.

Approach:
    - Filter to markets with at least one valid timestamp
    - Use coalesce(market_start_time, market_end_time) to handle early Polymarket
      markets where market_start_time is null (including the $1.43B Trump election
      market). Falls back to market_end_time to preserve these markets in the
      correct time period.
    - Truncate to month and group by category

Note: Volume is attributed to the month the market was created (start/end time),
not the month trades were executed. Long-duration futures markets (e.g. season-long
NFL winner markets) will appear in their creation month rather than their peak
trading month. This is a known limitation of the current pipeline.

Grain: one row per month per category
*/

*/

with categorized as (
    select * from {{ ref('int_markets_categorized') }}
    where coalesce(market_start_time, market_end_time) is not null
)

select
    cast(date_trunc('month', coalesce(market_start_time, market_end_time)) as date) as month,
    category,
    count(*) as markets_created,
    sum(total_volume_usdc) as total_volume,
    round(avg(total_volume_usdc), 2) as avg_volume_per_market,
    sum(total_trades) as total_trades,
    sum(unique_traders) as total_unique_traders
from categorized
group by 1, 2
order by 1, 2
