/*
Purpose: Assign a category to each market based on its Polymarket tags field.

Approach:
    - Maintain a keyword-to-category mapping (category_map) with an explicit priority column
    - For each market, find the first matching keyword ordered by priority (ascending)
    - If no keyword matches, default to 'Other'

Priority ordering (lower = wins conflicts):
    1. Politics       — high-stakes, episodic markets; should never be misclassified
    2. Sports         — broad but distinct tag vocabulary
    3. Crypto         — unambiguous keywords, large market count
    4. Entertainment  — culture/media markets
    5. Tech & Science — AI, tech company markets
    6. Finance        — macro/rates/commodities
    7. Weather        — narrow, well-defined
    8. Business       — catch-all for company-specific markets

Limitations:
    - Keyword matching is case-insensitive but lexical — no semantic understanding
    - Markets with ambiguous or missing tags may be misclassified or fall through to 'Other'
    - Full accuracy (~99%) would require LLM classification on the question text,
      which is feasible via Claude Haiku at low cost but out of scope for this analysis
*/

with markets as (
    select * from {{ ref('fct_markets') }}
),

category_map as (
    select * from (values
        -- Politics (priority 1 — highest, wins all conflicts)
        ('Politics', 'Politics', 1),
        ('Politics', 'Elections', 1),
        ('Politics', 'Trump', 1),
        ('Politics', 'Biden', 1),
        ('Politics', 'Geopolitics', 1),
        ('Politics', 'Iran', 1),
        ('Politics', 'Ukraine', 1),
        ('Politics', 'Gaza', 1),
        ('Politics', 'Middle East', 1),
        ('Politics', 'Russia', 1),
        ('Politics', 'China', 1),
        ('Politics', 'world affairs', 1),
        ('Politics', 'Global Elections', 1),
        ('Politics', 'USA Election', 1),
        ('Politics', 'war', 1),
        ('Politics', 'nato', 1),
        ('Politics', 'Kamala', 1),
        ('Politics', 'North Korea', 1),
        ('Politics', 'Syria', 1),
        ('Politics', 'Trade War', 1),
        ('Politics', 'Military Actions', 1),

        -- Sports (priority 2)
        ('Sports', 'Sports', 2),
        ('Sports', 'Tennis', 2),
        ('Sports', 'Soccer', 2),
        ('Sports', 'football', 2),
        ('Sports', 'NFL', 2),
        ('Sports', 'NBA', 2),
        ('Sports', 'Golf', 2),
        ('Sports', 'UFC', 2),
        ('Sports', 'Boxing', 2),
        ('Sports', 'Chess', 2),
        ('Sports', 'Formula 1', 2),
        ('Sports', 'Esports', 2),
        ('Sports', 'EPL', 2),
        ('Sports', 'La Liga', 2),
        ('Sports', 'baseball', 2),
        ('Sports', 'MLB', 2),
        ('Sports', 'Parlays', 2),
        ('Sports', 'Wimbledon', 2),
        ('Sports', 'Basketball', 2),
        ('Sports', 'Champions League', 2),

        -- Crypto (priority 3)
        ('Crypto', 'Crypto', 3),
        ('Crypto', 'blockchain', 3),
        ('Crypto', 'Bitcoin', 3),
        ('Crypto', 'Ethereum', 3),
        ('Crypto', 'Solana', 3),
        ('Crypto', 'fdv', 3),
        ('Crypto', 'nfts', 3),
        ('Crypto', 'binance', 3),
        ('Crypto', 'Crypto Prices', 3),
        ('Crypto', 'Prediction Markets', 3),
        ('Crypto', 'Airdrops', 3),

        -- Entertainment (priority 4)
        ('Entertainment', 'Culture', 4),
        ('Entertainment', 'Movies', 4),
        ('Entertainment', 'Music', 4),
        ('Entertainment', 'Awards', 4),
        ('Entertainment', 'Celebrities', 4),
        ('Entertainment', 'MrBeast', 4),
        ('Entertainment', 'Elon Musk', 4),
        ('Entertainment', 'musk', 4),
        ('Entertainment', 'Twitter', 4),
        ('Entertainment', 'YouTube', 4),
        ('Entertainment', 'TikTok', 4),
        ('Entertainment', 'netflix', 4),
        ('Entertainment', 'box office', 4),
        ('Entertainment', 'Taylor Swift', 4),
        ('Entertainment', 'Kanye', 4),
        ('Entertainment', 'joe rogan', 4),
        ('Entertainment', 'App Store', 4),
        ('Entertainment', 'social media', 4),
        ('Entertainment', 'SBF', 4),
        ('Entertainment', 'entertainment', 4),

        -- Tech & Science (priority 5)
        ('Tech & Science', 'AI', 5),
        ('Tech & Science', 'Science', 5),
        ('Tech & Science', 'Tech', 5),
        ('Tech & Science', 'technology', 5),
        ('Tech & Science', 'SpaceX', 5),
        ('Tech & Science', 'Apple', 5),
        ('Tech & Science', 'OpenAI', 5),
        ('Tech & Science', 'gpt', 5),
        ('Tech & Science', 'anthropic', 5),
        ('Tech & Science', 'sam altman', 5),
        ('Tech & Science', 'video games', 5),
        ('Tech & Science', 'gaming', 5),

        -- Finance (priority 6)
        ('Finance', 'Finance', 6),
        ('Finance', 'Fed', 6),
        ('Finance', 'Inflation', 6),
        ('Finance', 'Economy', 6),
        ('Finance', 'GDP', 6),
        ('Finance', 'Earnings', 6),
        ('Finance', 'unemployment', 6),
        ('Finance', 'interest rates', 6),
        ('Finance', 'Oil', 6),
        ('Finance', 'Commodities', 6),
        ('Finance', 'Stocks', 6),
        ('Finance', 'real estate', 6),
        ('Finance', 'employment', 6),
        ('Finance', 'jobs', 6),
        ('Finance', 'Pre-Market', 6),

        -- Weather (priority 7)
        ('Weather', 'Weather', 7),
        ('Weather', 'earthquake', 7),
        ('Weather', 'Wildfire', 7),

        -- Business (priority 8)
        ('Business', 'Business', 8),
        ('Business', 'amazon', 8),
        ('Business', 'Tesla', 8)

    ) as t(category, keyword, priority)
)

select
    m.*,
    coalesce(
        (select cm.category
         from category_map cm
         where m.tags ilike '%' || cm.keyword || '%'
         order by cm.priority asc
         limit 1),
        'Other'
    ) as category
from markets m
