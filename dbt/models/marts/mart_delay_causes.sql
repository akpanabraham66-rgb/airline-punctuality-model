-- mart_delay_causes: delay minutes by cause, one row per date, airline and
-- departure airport (the grain). Only operated flights arriving 15 or more
-- minutes late, because BTS reports delay causes only for these.
--   Reactionary share = late_aircraft_minutes / total_cause_minutes

with delayed as (

    select *
    from {{ ref('fct_flights') }}
    where is_operated
      and arr_delay_minutes >= 15

)

select
    flight_date,
    carrier_code,
    origin_airport,

    count(*)                                          as delayed_flights,
    coalesce(sum(carrier_delay_minutes), 0)           as carrier_minutes,
    coalesce(sum(weather_delay_minutes), 0)           as weather_minutes,
    coalesce(sum(nas_delay_minutes), 0)               as nas_minutes,
    coalesce(sum(security_delay_minutes), 0)          as security_minutes,
    coalesce(sum(late_aircraft_delay_minutes), 0)     as late_aircraft_minutes,
    coalesce(sum(carrier_delay_minutes), 0)
      + coalesce(sum(weather_delay_minutes), 0)
      + coalesce(sum(nas_delay_minutes), 0)
      + coalesce(sum(security_delay_minutes), 0)
      + coalesce(sum(late_aircraft_delay_minutes), 0) as total_cause_minutes

from delayed
group by flight_date, carrier_code, origin_airport
