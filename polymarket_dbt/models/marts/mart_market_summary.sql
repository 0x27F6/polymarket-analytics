with categorized as (
    select * 
    from {{ref('int_markets_categorized')}}
),

category_summary as (
    select 
        category,
        count(*) as total_markets,
        -- aggregation by sum
        sum(total_volume_usdc) as total_volume,
        sum(total_shares_traded) as total_notional_volume,
        sum(total_trades) as total_trades,
        sum(unique_traders) as total_unique_traders,
        -- aggregation by average
        avg(date_diff('hour', market_start_time,market_end_time)) avg_market_length,
        avg(total_volume_usdc) as avg_volume,
        avg(total_shares_traded) as avg_notional_vol,
        avg(total_trades) as avg_trade_count,
        avg(unique_traders) as avg_unique_traders,
        --aggregation by median 
        approx_quantile(date_diff('hour', market_start_time, market_end_time), 0.5) as median_market_length,
        approx_quantile(total_volume_usdc, 0.5) as median_volume,
        approx_quantile(total_shares_traded, 0.5) as median_notional_volume,
        approx_quantile(total_trades, 0.5) as median_trade_count,
        approx_quantile(unique_traders, 0.5) as median_unique_traders
    from categorized 
    group by category
),

summary_rounded as (
    select 
        category,
        -- market level 
        total_markets,
        round(total_volume) as total_volume,
        round(total_notional_volume) as total_notional_volume,
        -- average by category 
        round(avg_market_length) as avg_market_length_hours,
        round(avg_volume) as avg_volume,
        round(avg_notional_vol) as avg_notional_vol,
        round(avg_trade_count) as avg_trade_count,
        round(avg_unique_traders) as avg_unique_traders,
        -- median by category 
        round(median_volume) as median_volume,
        round(median_notional_volume) as median_notional_volume,
        round(median_market_length) as median_market_length, 
        median_trade_count,
        median_unique_traders
    from category_summary 
)

select *
from summary_rounded 
order by total_markets desc