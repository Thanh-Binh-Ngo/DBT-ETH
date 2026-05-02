{{ config(grants = {'select': ['TESTER']}) }}

select
    BLOCK_HASH,
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    DATE,
    FROM_ADDRESS,
    TO_ADDRESS,
    LAST_MODIFIED,
    LOG_INDEX,
    TOKEN_ADDRESS,
    TRANSACTION_HASH,
    VALUE
from {{ source('src_eth', 'TOKEN_TRANSFERS') }}
