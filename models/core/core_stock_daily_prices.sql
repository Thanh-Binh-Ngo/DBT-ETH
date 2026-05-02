select
    ticker,
    price_date,
    open_price,
    high_price,
    low_price,
    close_price,
    adj_close_price,
    volume,
    source_system,
    loaded_at,

    round(high_price - low_price, 4)                                        as price_range,

    round(
        lag(close_price) over (partition by ticker order by price_date),
        4
    )                                                                        as prev_close_price,

    round(
        (close_price - lag(close_price) over (partition by ticker order by price_date))
        / nullif(lag(close_price) over (partition by ticker order by price_date), 0),
        6
    )                                                                        as daily_return,

    case
        when close_price > lag(close_price) over (partition by ticker order by price_date)
        then true
        else false
    end                                                                      as is_up_day

from {{ ref('stg_stock_daily_prices') }}
