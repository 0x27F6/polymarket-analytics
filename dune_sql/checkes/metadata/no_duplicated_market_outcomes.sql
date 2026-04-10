-- References dune_sql/metadata.sql 
-- Dune Query: https://dune.com/queries/6932485

-- Expectation:
-- Each (unique_key, condition_id) appears only once after deduplication
-- Should return 0 rows


with final as ( 
    select  
        unique_key,
        condition_id,
        question,
        neg_risk,
        market_start_time,
        market_end_time,
        outcome,
        tags
    from market_metadata 
    where rn = 1
)

select 
    unique_key,
    condition_id,
    count(*) as row_count
from final
group by 1,2
having count(*) > 1;
