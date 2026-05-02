select
    c.ADDRESS              as CONTRACT_ADDRESS,
    c.DATE                 as DEPLOYMENT_DATE,
    count(tt.TRANSACTION_HASH)  as TOTAL_TRANSFERS,
    sum(tt.VALUE)               as TOTAL_VOLUME,
    min(tt.BLOCK_TIMESTAMP)     as FIRST_TRANSFER_AT,
    max(tt.BLOCK_TIMESTAMP)     as LAST_TRANSFER_AT
from {{ ref('stg_eth_contracts') }} c
left join {{ ref('stg_eth_token_transfers') }} tt
    on tt.TOKEN_ADDRESS = c.ADDRESS
group by
    c.ADDRESS,
    c.DATE
