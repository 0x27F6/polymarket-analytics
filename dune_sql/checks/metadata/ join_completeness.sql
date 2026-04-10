

/*
Test: Metadata Join Completeness
Dependencies: dune_sql/metadata  OR https://dune.com/queries/6932485 

Expectation:
All qualified markets (>= $10k scoped volume) must have corresponding metadata.

Returns:
Any markets missing metadata (should be 0 rows)
*/

with 

scoped_trades as (
    select 
        cast(unique_key as varchar) as unique_key,
        amount
    from polymarket_polygon.market_trades
    where taker in (
        0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e,
        0xc5d563a36ae78145c45a50134d48a1215220f80a
    )
),

qualified_markets as (
    select unique_key
    from scoped_trades
    group by unique_key
    having sum(amount) >= 10000
),

market_metadata as (
    select distinct
        cast(unique_key as varchar) as unique_key
    from polymarket_polygon.market_details
)

select 
    qm.unique_key
from qualified_markets qm
left join market_metadata md
    on qm.unique_key = md.unique_key
where md.unique_key is null
