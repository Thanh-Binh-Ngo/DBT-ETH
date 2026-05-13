{{ config(tags=['finance']) }}
SELECT
    ticker,
    price_date,
    open_price,
    high_price,
    low_price,
    close_price,
    adj_close_price,
    volume,
    source_system,
    loaded_at
FROM {{ source('src_finance', 'yahoo_daily_prices') }}
