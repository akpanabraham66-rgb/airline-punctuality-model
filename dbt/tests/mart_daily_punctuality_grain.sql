-- Grain test: one row per date, airline and departure airport.
-- A singular test fails if it returns any rows; here, any key that appears twice.

select
    flight_date,
    carrier_code,
    origin_airport,
    count(*) as rows_for_this_key
from {{ ref('mart_daily_punctuality') }}
group by flight_date, carrier_code, origin_airport
having count(*) > 1
