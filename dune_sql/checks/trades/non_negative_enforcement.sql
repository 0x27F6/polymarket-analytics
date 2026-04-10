-- Dune Query: https://dune.com/queries/6979343

/*
Purpose: Check to see if any negative value trades occurred in our 
observed universe(should be impossible)

Expected outcome: Return no rows 

Note: Dune query linked above, can be run as is.

*/

with 

scoped_trades as (
    select 
        cast(unique_key as varchar) as unique_key,
        tx_hash,
        amount
    from polymarket_polygon.market_trades
    where taker in (
        0x4bfb41d5b3570defd03c39a9a4d8de6bd8b8982e,
        0xc5d563a36ae78145c45a50134d48a1215220f80a
    )
),

market_stats as (
    select 
        unique_key,
        sum(amount) as market_volume
    from scoped_trades
    group by unique_key
),

qualified_markets as (
    select unique_key
    from market_stats
    where market_volume >= 10000
)

select
    st.unique_key,
    st.tx_hash,
    st.amount
from scoped_trades st
join qualified_markets qm
    on st.unique_key = qm.unique_key
where st.amount < 0
