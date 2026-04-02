-- models/marts/mart_category_power_law.sql
with categorized as (
    select *,
        row_number() over (partition by category order by total_volume_usdc desc) as category_rank
    from {{ ref('int_markets_categorized') }}
),

category_totals as (
    select category, sum(total_volume_usdc) as category_volume
    from categorized
    group by category
)

select
    c.category,
    -- raw volumes
    round(ct.category_volume) as category_volume,
    round(sum(case when category_rank <= 10 then total_volume_usdc else 0 end)) as top_10_volume,
    round(sum(case when category_rank <= 50 then total_volume_usdc else 0 end)) as top_50_volume,
    round(sum(case when category_rank <= 100 then total_volume_usdc else 0 end)) as top_100_volume,
    -- volumes in millions
    round(ct.category_volume / 1e6, 1) as category_vol_m,
    round(sum(case when category_rank <= 10 then total_volume_usdc else 0 end) / 1e6, 1) as top_10_vol_m,
    round(sum(case when category_rank <= 50 then total_volume_usdc else 0 end) / 1e6, 1) as top_50_vol_m,
    round(sum(case when category_rank <= 100 then total_volume_usdc else 0 end) / 1e6, 1) as top_100_vol_m,
    -- percentages
    round(sum(case when category_rank <= 10 then total_volume_usdc else 0 end) * 100.0 / ct.category_volume, 2) as top_10_pct,
    round(sum(case when category_rank <= 50 then total_volume_usdc else 0 end) * 100.0 / ct.category_volume, 2) as top_50_pct,
    round(sum(case when category_rank <= 100 then total_volume_usdc else 0 end) * 100.0 / ct.category_volume, 2) as top_100_pct
from categorized c
join category_totals ct on c.category = ct.category
group by c.category, ct.category_volume
order by ct.category_volume desc