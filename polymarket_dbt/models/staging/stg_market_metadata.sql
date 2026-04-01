with

source as (
    select *
    from read_csv('../data/raw/market_metadata.csv')

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