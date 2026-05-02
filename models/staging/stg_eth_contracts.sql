{{ config(grants = {'select': ['TESTER']}) }}

select
    ADDRESS,
    BLOCK_HASH,
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    BYTECODE,
    DATE,
    LAST_MODIFIED
from {{ source('src_eth', 'CONTRACTS') }}
