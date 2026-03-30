select * 
from {{ source('src_eth', 'TOKEN_TRANSFERS') }}
