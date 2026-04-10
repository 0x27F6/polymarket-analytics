/*
Purpose:
Pull metadata for the same set of markets used in the trading analysis:
https://dune.com/queries/6932485

Approach:
- Recreate the market universe using a taker-based trade filter
- Restrict to markets with >= $10,000 volume (based only on filtered trades)
- Join to market_details to extract metadata
- Deduplicate to one row per (unique_key, condition_id)

Note: taker filter removes duplication of transactions 

*/

with 

-- 1) Define the scoped trade universe
-- Only includes trades routed through specific taker addresses
scoped_trades as (
    select 
        cast(unique_key as varchar) as unique_key,      -- market identifier
        cast(condition_id as varchar) as condition_id,  -- outcome identifier
        amount,                                         -- trade volume (USDC)
        shares,
        tx_hash,
        maker
    from polymarket_polygon.market_trades
    where taker in (
        0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e,
        0xc5d563a36ae78145c45a50134d48a1215220f80a
    )
),

-- 2) Identify markets with meaningful liquidity
-- Threshold applied on scoped trades (not full market volume)
qualified_markets as (
    select 
        unique_key
    from scoped_trades
    group by unique_key
    having sum(amount) >= 10000
),

-- 3) Pull metadata only for qualified markets
-- Join used to explicitly define dataset boundary
market_metadata as (
    select 
        md.unique_key,
        md.condition_id,
        md.event_market_id,
        md.question,
        md.neg_risk,
        md.market_start_time,
        md.market_end_time,
        md.outcome,
        md.tags,

        -- Deduplicate rows per (unique_key, condition_id)
        -- token_outcome provides deterministic ordering
        row_number() over (
            partition by md.unique_key, md.condition_id 
            order by md.token_outcome
        ) as rn

    from polymarket_polygon.market_details md
    join qualified_markets qm
        on md.unique_key = qm.unique_key
),

-- 4) Select one canonical row per market-outcome pair
final as (
    select  
        unique_key,
        condition_id,
        question,
        neg_risk,
        market_start_time,
        market_end_time,
        outcome,
        tags
    from market_metadata 
    where rn = 1
)

-- Final output: metadata aligned with filtered trading universe
select * 
from final;
