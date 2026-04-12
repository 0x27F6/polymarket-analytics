/*
Purpose: Aggregate trades to the market grain.
https://dune.com/queries/6932269

Approach:
- Query categories required for aggregation
- Deduplicate using taker-sided address filter (Neg-Risk and CTF contract addresses)
- Compute volume traded at the market grain
- Aggregate scoped trades and filter out markets with less than 10,000 lifetime volume

*/
with 

-- 1) Define the scoped dataset -- taker sided deduplication
scoped_trades as (
    select 
        cast(unique_key as varchar) as unique_key,
        cast(condition_id as varchar) as condition_id,
        amount,
        shares,
        tx_hash,
        maker
    from polymarket_polygon.market_trades
    where taker in (
        0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e,
        0xc5d563a36ae78145c45a50134d48a1215220f80a
    )
),

-- 2) Compute market-level stats once 
market_stats as (
    select 
        unique_key,
        sum(amount) as market_volume
    from scoped_trades
    group by unique_key
),

-- 3) Restrict to sufficiently liquid markets
qualified_markets as (
    select unique_key
    from market_stats
    where market_volume >= 10000
),

-- 4) Final aggregation at market + condition level
market_outcome_stats as (
    select 
        st.unique_key,
        st.condition_id,
        sum(st.amount) as total_volume_usdc,
        sum(st.shares) as total_shares_traded,
        count(distinct st.tx_hash) as total_trades,
        count(distinct st.maker) as unique_traders
    from scoped_trades st
    where st.unique_key in (select unique_key from qualified_markets)
    group by st.unique_key, st.condition_id
)

select * from market_outcome_stats
