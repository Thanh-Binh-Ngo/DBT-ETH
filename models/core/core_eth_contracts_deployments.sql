select
    c.ADDRESS,
    c.BLOCK_NUMBER         as DEPLOYMENT_BLOCK_NUMBER,
    c.BLOCK_TIMESTAMP      as DEPLOYMENT_TIMESTAMP,
    c.DATE                 as DEPLOYMENT_DATE,
    t.HASH                 as DEPLOYMENT_TX_HASH,
    t.FROM_ADDRESS         as DEPLOYER_ADDRESS,
    t.RECEIPT_GAS_USED     as DEPLOYMENT_GAS_USED,
    t.RECEIPT_EFFECTIVE_GAS_PRICE as DEPLOYMENT_GAS_PRICE,
    t.RECEIPT_STATUS       as DEPLOYMENT_STATUS
from {{ ref('stg_eth_contracts') }} c
left join {{ ref('stg_eth_transactions') }} t
    on t.RECEIPT_CONTRACT_ADDRESS = c.ADDRESS
