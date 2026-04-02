-- models/marts/mart_market_creation_trends.sql
with categorized as (
    select * from {{ ref('int_markets_categorized') }}
    where market_start_time is not null
)

select
    cast(date_trunc('month', market_start_time) as date)  as month,
    category,
    count(*) as markets_created,
    sum(total_volume_usdc) as total_volume,
    round(avg(total_volume_usdc), 2) as avg_volume_per_market,
    sum(total_trades) as total_trades,
    sum(unique_traders) as total_unique_traders
from categorized
group by 1, 2
order by 1, 2