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
        m.market_start_time,
        m.market_end_time,
        m.outcome,
        t.total_volume_usdc,
        t.total_shares_traded,
        t.total_trades,
        t.unique_traders,
        m.tags
    from metadata m
    -- inner join intentionally excludes condition_ids below threshold on split NegRisk outcomes
    join trades t
        on m.unique_key = t.unique_key
        and m.condition_id = t.condition_id 
)

select * from joined 