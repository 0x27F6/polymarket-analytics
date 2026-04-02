-- models/marts/mart_volume_power_law.sql

with ranked as (
    select
        unique_key,
        condition_id,
        question,
        category,
        total_volume_usdc,
        row_number() over (order by total_volume_usdc desc) as volume_rank,
        count(*) over () as total_markets,
        sum(total_volume_usdc) over () as total_volume
    from {{ ref('int_markets_categorized') }}
),

cumulative as (
    select
        *,
        sum(total_volume_usdc) over (order by volume_rank) as cumulative_volume,
        round(volume_rank * 100.0 / total_markets, 4) as market_pct,
        round(sum(total_volume_usdc) over (order by volume_rank) * 100.0 / total_volume, 4) as cumulative_vol_pct
    from ranked
)

select * from cumulative
order by volume_rank