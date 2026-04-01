with 

source as (
    select *
    from raw_market_trades
)

select 
    unique_key,
    condition_id,
    total_volume_usdc,
    total_shares_traded,
    total_trades,
    unique_traders
from source 