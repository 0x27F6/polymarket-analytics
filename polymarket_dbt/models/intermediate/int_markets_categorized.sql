-- models/intermediate/int_markets_categorized.sql
with markets as (
    select * from {{ ref('fct_markets') }}
)

select
    *,
    case
        when tags like 'Crypto%' or tags like 'blockchain%' or tags like 'Bitcoin%' or tags like 'Ethereum%' or tags like 'Solana%' or tags like 'fdv%' or tags like 'nfts%' or tags like 'binance%' or tags like 'Crypto Prices%' or tags like 'Prediction Markets%' or tags like 'Airdrops%' then 'Crypto'
        when tags like 'Sports%' or tags like 'Tennis%' or tags like 'Soccer%' or tags like 'football%' or tags like 'NFL%' or tags like 'NBA%' or tags like 'Golf%' or tags like 'UFC%' or tags like 'Boxing%' or tags like 'Chess%' or tags like 'Formula 1%' or tags like 'Esports%' or tags like 'EPL%' or tags like 'La Liga%' or tags like 'baseball%' or tags like 'MLB%' or tags like 'Parlays%' or tags like 'Wimbledon%' or tags like 'Basketball%' or tags like 'Champions League%' then 'Sports'
        when tags like 'Politics%' or tags like 'Elections%' or tags like 'Trump%' or tags like 'Biden%' or tags like 'Geopolitics%' or tags like 'Iran%' or tags like 'Ukraine%' or tags like 'Gaza%' or tags like 'Middle East%' or tags like 'Russia%' or tags like 'China%' or tags like 'world affairs%' or tags like 'Global Elections%' or tags like 'USA Election%' or tags like 'war%' or tags like 'nato%' or tags like 'Kamala%' or tags like 'North Korea%' or tags like 'Syria%' or tags like 'Trade War%' or tags like 'Military Actions%' then 'Politics'
        when tags like 'Finance%' or tags like 'Fed%' or tags like 'Inflation%' or tags like 'Economy%' or tags like 'GDP%' or tags like 'Earnings%' or tags like 'unemployment%' or tags like 'interest rates%' or tags like 'Oil%' or tags like 'Commodities%' or tags like 'Stocks%' or tags like 'real estate%' or tags like 'employment%' or tags like 'jobs%' or tags like 'Pre-Market%' then 'Finance'
        when tags like 'Weather%' or tags like 'earthquake%' or tags like 'Wildfire%' then 'Weather'
        when tags like 'AI%' or tags like 'Science%' or tags like 'Tech%' or tags like 'technology%' or tags like 'SpaceX%' or tags like 'Apple%' or tags like 'OpenAI%' or tags like 'gpt%' or tags like 'anthropic%' or tags like 'sam altman%' or tags like 'video games%' or tags like 'gaming%' then 'Tech & Science'
        when tags like 'Culture%' or tags like 'Movies%' or tags like 'Music%' or tags like 'Awards%' or tags like 'Celebrities%' or tags like 'MrBeast%' or tags like 'Elon Musk%' or tags like 'musk%' or tags like 'Twitter%' or tags like 'YouTube%' or tags like 'TikTok%' or tags like 'netflix%' or tags like 'box office%' or tags like 'Taylor Swift%' or tags like 'Kanye%' or tags like 'joe rogan%' or tags like 'App Store%' or tags like 'social media%' or tags like 'SBF%' or tags like 'entertainment%' then 'Entertainment'
        when tags like 'Business%' or tags like 'amazon%' or tags like 'Tesla%' then 'Business'
        else 'Other'
    end as category
from markets
