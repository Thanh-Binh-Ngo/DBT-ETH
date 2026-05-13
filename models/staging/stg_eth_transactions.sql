{{
    config(
        materialized='incremental',
        incremental_strategy='delete+insert',
        unique_key='HASH',
        grants={'select': ['TESTER']}
    )
}}

select
    BLOCK_HASH,
    BLOCK_NUMBER,
    BLOCK_TIMESTAMP,
    DATE,
    FROM_ADDRESS,
    GAS,
    GAS_PRICE,
    HASH,
    INPUT,
    LAST_MODIFIED,
    MAX_FEE_PER_GAS,
    MAX_PRIORITY_FEE_PER_GAS,
    NONCE,
    RECEIPT_CONTRACT_ADDRESS,
    RECEIPT_CUMULATIVE_GAS_USED,
    RECEIPT_EFFECTIVE_GAS_PRICE,
    RECEIPT_GAS_USED,
    RECEIPT_STATUS,
    TO_ADDRESS,
    TRANSACTION_INDEX,
    TRANSACTION_TYPE,
    VALUE
from {{ source('src_eth', 'TRANSACTIONS') }}

{% if is_incremental() %}
    where BLOCK_TIMESTAMP > (select max(BLOCK_TIMESTAMP) from {{ this }})
{% endif %}
