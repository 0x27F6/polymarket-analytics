-- models/intermediate/int_markets_categorized.sql

with markets as (
    select * from {{ ref('fct_markets') }}
),

category_map as (
    select * from (values
        -- Crypto
        ('Crypto', 'Crypto'),
        ('Crypto', 'blockchain'),
        ('Crypto', 'Bitcoin'),
        ('Crypto', 'Ethereum'),
        ('Crypto', 'Solana'),
        ('Crypto', 'fdv'),
        ('Crypto', 'nfts'),
        ('Crypto', 'binance'),
        ('Crypto', 'Crypto Prices'),
        ('Crypto', 'Prediction Markets'),
        ('Crypto', 'Airdrops'),

        -- Sports
        ('Sports', 'Sports'),
        ('Sports', 'Tennis'),
        ('Sports', 'Soccer'),
        ('Sports', 'football'),
        ('Sports', 'NFL'),
        ('Sports', 'NBA'),
        ('Sports', 'Golf'),
        ('Sports', 'UFC'),
        ('Sports', 'Boxing'),
        ('Sports', 'Chess'),
        ('Sports', 'Formula 1'),
        ('Sports', 'Esports'),
        ('Sports', 'EPL'),
        ('Sports', 'La Liga'),
        ('Sports', 'baseball'),
        ('Sports', 'MLB'),
        ('Sports', 'Parlays'),
        ('Sports', 'Wimbledon'),
        ('Sports', 'Basketball'),
        ('Sports', 'Champions League'),

        -- Politics
        ('Politics', 'Politics'),
        ('Politics', 'Elections'),
        ('Politics', 'Trump'),
        ('Politics', 'Biden'),
        ('Politics', 'Geopolitics'),
        ('Politics', 'Iran'),
        ('Politics', 'Ukraine'),
        ('Politics', 'Gaza'),
        ('Politics', 'Middle East'),
        ('Politics', 'Russia'),
        ('Politics', 'China'),
        ('Politics', 'world affairs'),
        ('Politics', 'Global Elections'),
        ('Politics', 'USA Election'),
        ('Politics', 'war'),
        ('Politics', 'nato'),
        ('Politics', 'Kamala'),
        ('Politics', 'North Korea'),
        ('Politics', 'Syria'),
        ('Politics', 'Trade War'),
        ('Politics', 'Military Actions'),

        -- Finance
        ('Finance', 'Finance'),
        ('Finance', 'Fed'),
        ('Finance', 'Inflation'),
        ('Finance', 'Economy'),
        ('Finance', 'GDP'),
        ('Finance', 'Earnings'),
        ('Finance', 'unemployment'),
        ('Finance', 'interest rates'),
        ('Finance', 'Oil'),
        ('Finance', 'Commodities'),
        ('Finance', 'Stocks'),
        ('Finance', 'real estate'),
        ('Finance', 'employment'),
        ('Finance', 'jobs'),
        ('Finance', 'Pre-Market'),

        -- Weather
        ('Weather', 'Weather'),
        ('Weather', 'earthquake'),
        ('Weather', 'Wildfire'),

        -- Tech & Science
        ('Tech & Science', 'AI'),
        ('Tech & Science', 'Science'),
        ('Tech & Science', 'Tech'),
        ('Tech & Science', 'technology'),
        ('Tech & Science', 'SpaceX'),
        ('Tech & Science', 'Apple'),
        ('Tech & Science', 'OpenAI'),
        ('Tech & Science', 'gpt'),
        ('Tech & Science', 'anthropic'),
        ('Tech & Science', 'sam altman'),
        ('Tech & Science', 'video games'),
        ('Tech & Science', 'gaming'),

        -- Entertainment / Culture
        ('Entertainment', 'Culture'),
        ('Entertainment', 'Movies'),
        ('Entertainment', 'Music'),
        ('Entertainment', 'Awards'),
        ('Entertainment', 'Celebrities'),
        ('Entertainment', 'MrBeast'),
        ('Entertainment', 'Elon Musk'),
        ('Entertainment', 'musk'),
        ('Entertainment', 'Twitter'),
        ('Entertainment', 'YouTube'),
        ('Entertainment', 'TikTok'),
        ('Entertainment', 'netflix'),
        ('Entertainment', 'box office'),
        ('Entertainment', 'Taylor Swift'),
        ('Entertainment', 'Kanye'),
        ('Entertainment', 'joe rogan'),
        ('Entertainment', 'App Store'),
        ('Entertainment', 'social media'),
        ('Entertainment', 'SBF'),
        ('Entertainment', 'entertainment'),

        -- Business
        ('Business', 'Business'),
        ('Business', 'amazon'),
        ('Business', 'Tesla')
    ) as t(category, keyword)
)

select
    m.*,
    coalesce(
        (select cm.category
         from category_map cm
         where m.tags ilike cm.keyword || '%'
         limit 1),
        'Other'
    ) as category
from markets m
