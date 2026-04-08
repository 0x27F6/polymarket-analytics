with

markets as (
    select * from {{ ref('int_markets_categorized') }}
),

ranked as (
    select
        unique_key,
        total_volume_usdc,
        percent_rank() over (order by total_volume_usdc desc) as pct_rank
    from markets
),

total as (
    select
        count(*) as total_markets,
        sum(total_volume_usdc) as total_volume
    from markets
),

buckets as (
    select 'top 1%' as bucket, 0.01 as threshold, 'lte' as direction union all
    select 'top 5%',  0.05, 'lte' union all
    select 'top 10%', 0.10, 'lte' union all
    select 'top 25%', 0.25, 'lte' union all
    select 'bottom 50%', 0.50, 'gt'
),

bucket_stats as (
    select
        b.bucket,
        count(r.unique_key) as market_count,
        sum(r.total_volume_usdc) as bucket_volume
    from buckets b
    cross join ranked r
    cross join total t
    where (b.direction = 'lte' and r.pct_rank <= b.threshold)
       or (b.direction = 'gt' and r.pct_rank > b.threshold)
    group by b.bucket
)

select
    s.bucket,
    s.market_count,
    round(s.bucket_volume / 1e6, 2) as bucket_volume_millions,
    round(s.market_count * 100.0 / t.total_markets, 2) as pct_of_markets,
    round(s.bucket_volume * 100.0 / t.total_volume, 2) as pct_of_volume
from bucket_stats s
cross join total t
order by
    case bucket
        when 'top 1%' then 1
        when 'top 5%' then 2
        when 'top 10%' then 3
        when 'top 25%' then 4
        when 'bottom 50%' then 5
    end
