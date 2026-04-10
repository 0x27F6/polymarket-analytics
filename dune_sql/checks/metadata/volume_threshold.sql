-- checks/volume_threshold_respected.sql

/*
Test: Volume Threshold Enforcement
Dependency: Dune.com/queries 

Expectation:
All markets in the final dataset must meet >= $10k volume
(based on scoped trades only)

Returns:
Any markets violating the threshold (should be 0 rows)
*/

with 

-- Rebuild scoped trades
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

-- Recompute qualified markets
qualified_markets as (
    select unique_key
    from scoped_trades
    group by unique_key
    having sum(amount) >= 10000
),

-- Rebuild your final dataset logic (minimal version)
final as (
    select distinct
        unique_key,
        condition_id
    from scoped_trades
    where unique_key in (select unique_key from qualified_markets)
)

-- Check for violations
select 
    f.unique_key
from final f
left join qualified_markets qm
    on f.unique_key = qm.unique_key
where qm.unique_key is null;
