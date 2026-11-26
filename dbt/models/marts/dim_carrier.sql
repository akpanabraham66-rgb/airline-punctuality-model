-- dim_carrier: one row per airline (the grain), from the carriers seed.
-- The seed is typed by hand from the session 5 airline table.

select
    carrier_code,
    carrier_name
from {{ ref('carriers') }}
