select * 
from {{ source('src_eth', 'CONTRACTS') }}
