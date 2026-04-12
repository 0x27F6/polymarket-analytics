/*
Purpose: Platform-level volume concentration across all markets regardless of category.
Answers: "How much of total platform volume do the top N markets capture?"

Computes cumulative volume and % share for top 10, 50, 100, and 500 markets
by lifetime trading volume.

Distinction from mart_category_concentration:
    - mart_category_concentration measures within-category concentration
      (top N markets as a % of their category's volume)
    - This mart measures platform-wide concentration
      (top N markets as a % of all platform volume)

Approach:
    - top_markets_by_volume: ranks all markets by volume descending
    - total_market_volume: scalar subquery for total platform volume,
      used as denominator for % calculations
    - cross join to bring the scalar into the final select without a group by key

Grain: single row (platform-wide summary)
*/

with 

top_markets_by_volume as(
    select 
        unique_key,
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
