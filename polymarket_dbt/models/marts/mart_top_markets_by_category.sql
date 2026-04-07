with categorized as (
    select
        unique_key,
        question,
        neg_risk,
        category,
        total_volume_usdc,
        total_shares_traded,
        total_trades,
        unique_traders,
        market_start_time,
        market_end_time,
        row_number() over (partition by category order by total_volume_usdc desc) as rank
    from {{ ref('int_markets_categorized') }}
)

select *
from categorized
where rank <= 50
