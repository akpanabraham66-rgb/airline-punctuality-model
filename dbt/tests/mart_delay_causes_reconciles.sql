-- Reconciliation test: the mart's delay minutes must equal the minutes in
-- fct_flights for operated flights arriving 15 or more minutes late.
-- Returns one row (a failure) if the totals differ by more than half a minute.

with mart as (

    select
        sum(late_aircraft_minutes)  as mart_late_aircraft,
        sum(total_cause_minutes)    as mart_total
    from {{ ref('mart_delay_causes') }}

),

fact as (

    select
        coalesce(sum(late_aircraft_delay_minutes), 0)          as fact_late_aircraft,
        coalesce(sum(carrier_delay_minutes), 0)
          + coalesce(sum(weather_delay_minutes), 0)
          + coalesce(sum(nas_delay_minutes), 0)
          + coalesce(sum(security_delay_minutes), 0)
          + coalesce(sum(late_aircraft_delay_minutes), 0)      as fact_total
    from {{ ref('fct_flights') }}
    where is_operated
      and arr_delay_minutes >= 15

)

select *
from mart cross join fact
where abs(mart_late_aircraft - fact_late_aircraft) > 0.5
   or abs(mart_total - fact_total) > 0.5
