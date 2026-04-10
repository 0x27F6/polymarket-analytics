/*
Expectation:
Sum of outcome-level volume = total scoped volume (for qualified markets)

Returns:
Mismatches (should be 0 rows)

Dune Query: https://dune.com/queries/6979015
*/

with 

-- MUST match your pipeline schema
scoped_trades as (
    select 
        cast(unique_key as varchar) as unique_key,
        cast(condition_id as varchar) as condition_id,
        amount
    from polymarket_polygon.market_trades
    where taker in (
        0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e,
        0xc5d563a36ae78145c45a50134d48a1215220f80a
    )
),

-- same qualification logic
qualified_markets as (
    select unique_key
    from scoped_trades
    group by unique_key
    having sum(amount) >= 10000
),

-- base truth (market-level volume)
base as (
    select 
        unique_key,
        sum(amount) as base_volume
    from scoped_trades
    where unique_key in (select unique_key from qualified_markets)
    group by unique_key
),

-- your actual aggregation
final as (
    select 
        unique_key,
        condition_id,
        sum(amount) as total_volume_usdc
    from scoped_trades
    where unique_key in (select unique_key from qualified_markets)
    group by unique_key, condition_id
),

-- re-aggregate to market level
agg as (
    select 
        unique_key,
        sum(total_volume_usdc) as agg_volume
    from final
    group by unique_key
)

-- compare
select 
    b.unique_key,
    b.base_volume,
    a.agg_volume
from base b
join agg a
    on b.unique_key = a.unique_key
where abs(base_volume - agg_volume) > 0.01 -- account for floating point differences
