select
    d.ADDRESS,
    d.DEPLOYMENT_DATE,
    d.DEPLOYER_ADDRESS,
    d.DEPLOYMENT_TX_HASH,
    d.DEPLOYMENT_GAS_USED,
    --d.DEPLOYMENT_GAS_PRICE,
    d.DEPLOYMENT_STATUS,
    a.TOTAL_TRANSFERS,
    a.TOTAL_VOLUME,
    a.FIRST_TRANSFER_AT,
    a.LAST_TRANSFER_AT
from {{ ref('core_eth_contracts_deployments') }} d
left join {{ ref('core_eth_contracts_activity') }} a
    on a.CONTRACT_ADDRESS = d.ADDRESS
