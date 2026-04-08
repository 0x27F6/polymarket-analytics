with

markets as (
    select * from {{ ref('int_markets_categorized') }}
),

category_agg as (
    select
        category,
        count(*) as market_count,
        sum(total_volume_usdc) as total_volume
    from markets
    group by 1
),

totals as (
    select
        category,
        market_count,
        total_volume,
        sum(market_count) over () as total_markets,
        sum(total_volume) over () as platform_total_volume
    from category_agg
)

select
    category,
    market_count,
    round(total_volume / 1e6, 2) as total_volume_millions,
    round(market_count * 100.0 / total_markets, 2) as pct_of_markets,
    round(total_volume * 100.0 / platform_total_volume, 2) as pct_of_volume
from totals
order by total_volume desc
