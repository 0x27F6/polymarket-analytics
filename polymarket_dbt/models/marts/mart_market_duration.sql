-- models/marts/mart_market_duration.sql

with categorized as (
    select 
        *,
        date_diff('hour', market_start_time, market_end_time) as duration_hours
    from {{ ref('int_markets_categorized') }}
    where market_start_time is not null
      and market_end_time is not null
),

metrics as (
    select
        category,
        duration_hours,
        total_volume_usdc,
        total_volume_usdc / nullif(duration_hours, 0) as volume_per_hour
    from categorized
    where duration_hours > 0
      and total_volume_usdc is not null
)

select
    category,

    -- counts
    count(*) as market_count,

    -- duration stats
    round(avg(duration_hours), 1) as avg_duration_hours,
    approx_quantile(duration_hours, 0.5) as median_duration_hours,
    stddev(duration_hours) as duration_stddev,

    -- volume stats
    round(avg(total_volume_usdc)) as avg_volume,
    round(approx_quantile(total_volume_usdc, 0.5)) as median_volume,
    round(approx_quantile(total_volume_usdc, 0.9)) as p90_volume,
    round(approx_quantile(total_volume_usdc, 0.99)) as p99_volume,
    stddev(total_volume_usdc) as volume_stddev,

    -- volume density
    round(avg(volume_per_hour), 2) as avg_volume_per_hour,

    -- correlations
    corr(duration_hours, total_volume_usdc) as duration_volume_correlation,
    corr(duration_hours, volume_per_hour) as duration_vs_density_corr,
    corr(log(duration_hours + 1), log(total_volume_usdc + 1)) as log_log_corr,

    -- concentration
    sum(total_volume_usdc) as total_volume,
    max(total_volume_usdc) as max_market_volume,
    max(total_volume_usdc) / nullif(sum(total_volume_usdc), 0) as top_market_share,

    -- skew
    avg(total_volume_usdc) 
        / nullif(approx_quantile(total_volume_usdc, 0.5), 0) 
        as mean_to_median_volume_ratio,

    -- high value counts
    count(*) filter (where total_volume_usdc > 100000) as markets_over_100k,
    count(*) filter (where total_volume_usdc > 1000000) as markets_over_1m

from metrics
group by category
order by total_volume desc