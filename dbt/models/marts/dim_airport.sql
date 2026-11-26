-- dim_airport: one row per airport code (the grain) that appears as an origin
-- or a destination. The 17 BTS columns we downloaded give codes only, not names.

with airports as (

    select origin_airport as airport_code from {{ ref('stg_flights') }}

    union   -- union, not union all: keeps each code once, even if it appears in both lists

    select dest_airport from {{ ref('stg_flights') }}

)

select airport_code
from airports
