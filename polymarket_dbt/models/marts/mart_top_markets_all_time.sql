with 

top_markets_by_volume as(
    select 
        unique_key,
        condition_id,
        total_volume_usdc,
        row_number() over(order by total_volume_usdc desc) as volume_rank
    from {{ref('int_markets_categorized')}}
),

total_market_volume as(
    -- to be used as a scalar, no key or group by necessary 
    select sum(total_volume_usdc) all_time_volume
    from  {{ref('int_markets_categorized')}}
)

select
    round(sum(case when volume_rank <= 10 then total_volume_usdc else 0 end)) as top_10_volume,
    round(sum(case when volume_rank <= 50 then total_volume_usdc else 0 end)) as top_50_volume,
    round(sum(case when volume_rank <= 100 then total_volume_usdc else 0 end)) as top_100_volume,
    round(sum(case when volume_rank <= 500 then total_volume_usdc else 0 end)) as top_500_volume,
    round(t.all_time_volume) as all_time_volume,
    round(sum(case when volume_rank <= 10 then total_volume_usdc else 0 end) * 100.0 / t.all_time_volume, 2) as top_10_pct,
    round(sum(case when volume_rank <= 50 then total_volume_usdc else 0 end) * 100.0 / t.all_time_volume, 2) as top_50_pct,
    round(sum(case when volume_rank <= 100 then total_volume_usdc else 0 end) * 100.0 / t.all_time_volume, 2) as top_100_pct,
    round(sum(case when volume_rank <= 500 then total_volume_usdc else 0 end) * 100.0 / t.all_time_volume, 2) as top_500_pct
from top_markets_by_volume
cross join total_market_volume t
group by t.all_time_volume