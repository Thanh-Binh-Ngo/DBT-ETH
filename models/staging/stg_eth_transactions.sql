select * 
from {{ source('src_eth', 'TRANSACTIONS') }}
