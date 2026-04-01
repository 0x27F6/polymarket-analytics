with 

source as (
    select *
    from read_csv('../data/raw/market_trades.csv')
)

select 
    unique_key,
    condition_id,
    total_volume_usdc,
    total_shares_traded,
    total_trades,
    unique_traders
from source 