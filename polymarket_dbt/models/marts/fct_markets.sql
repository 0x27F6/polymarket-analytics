/*
Purpose: Join staged metadata and trade data to create a source of truth

Approach: 
- inner join on condition_id and unique key 
- collapse to the market level (required for negRisk markets: multiple condition_ids mapped to one unique_key)
- aggregate by SUM for integers or MAX for strings(pulls non-integer data lexicographically)


*/

with 

trades as (
    select * from {{ref('stg_market_trades')}}
),

metadata as (
    select * from {{ref('stg_market_metadata')}}
),

joined as (
    select 
        m.unique_key,
        m.condition_id,
        m.question,
        m.neg_risk,
        m.outcome,
        t.total_volume_usdc,
        t.total_shares_traded,
        t.total_trades,
        t.unique_traders,
        m.tags,
        m.market_start_time,
        m.market_end_time,
    from metadata m
    -- inner join intentionally excludes condition_ids below threshold on split NegRisk outcomes
    join trades t
        on m.unique_key = t.unique_key
        and m.condition_id = t.condition_id 
),

-- Collapse to market level
market_level as (
    select
        unique_key,
        max(question) as question,
        max(neg_risk) as neg_risk,
        max(tags) as tags,
        max(market_start_time) as market_start_time,
        max(market_end_time) as market_end_time,
        sum(total_volume_usdc) as total_volume_usdc,
        sum(total_shares_traded) as total_shares_traded,
        sum(total_trades) as total_trades,
        max(unique_traders) as unique_traders  -- max not sum, traders aren't additive across outcomes
    from joined
    group by unique_key
) 

select * 
from market_level 
