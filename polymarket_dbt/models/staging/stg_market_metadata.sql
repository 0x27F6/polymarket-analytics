with

source as (
    select *
    from raw_market_metadata

)

select
    unique_key,
    condition_id,
    question,
    neg_risk,
    market_start_time,
    market_end_time,
    outcome,
    tags
from source 