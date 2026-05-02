select
    ticker,
    price_date,
    close_price,
    adj_close_price,
    volume,
    daily_return,

    round(
        avg(close_price) over (
            partition by ticker
            order by price_date
            rows between 6 preceding and current row
        ),
        4
    )                                                                        as ma_7d,

    round(
        avg(close_price) over (
            partition by ticker
            order by price_date
            rows between 29 preceding and current row
        ),
        4
    )                                                                        as ma_30d,

    round(
        stddev(daily_return) over (
            partition by ticker
            order by price_date
            rows between 29 preceding and current row
        ),
        6
    )                                                                        as volatility_30d,

    round(
        avg(volume) over (
            partition by ticker
            order by price_date
            rows between 29 preceding and current row
        ),
        0
    )                                                                        as avg_volume_30d

from {{ ref('core_stock_daily_prices') }}
