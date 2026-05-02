select
    tt.TOKEN_ADDRESS,
    tt.DATE,
    count(tt.TRANSACTION_HASH)  as TOTAL_TRANSFERS,
    sum(tt.VALUE)               as TOTAL_VOLUME,
    count(distinct tt.FROM_ADDRESS) as UNIQUE_SENDERS,
    count(distinct tt.TO_ADDRESS)   as UNIQUE_RECEIVERS
from {{ ref('stg_eth_token_transfers') }} tt
group by
    tt.TOKEN_ADDRESS,
    tt.DATE
