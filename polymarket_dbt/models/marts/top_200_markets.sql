with 
markets as (
    select *
    from {{ref('int_markets_categorized')}}
),

markets_ranked as (
    select *,
        row_number() over(order by total_volume_usdc desc) as rn
    from markets
)

select * 
from markets_ranked 
where rn <= 200

