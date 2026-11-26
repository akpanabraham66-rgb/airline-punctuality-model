-- mart_daily_punctuality: one row per date, airline and departure airport (the grain).
-- Stores counts, not percentages, so any total in Power BI is exact:
--   A15                = on_time_flights          / operated_flights
--   D15                = departed_on_time_flights / departed_flights
--   Cancellation rate  = cancelled_flights        / scheduled_flights
-- The airport is the origin (departure) airport for every KPI.

select
    flight_date,
    carrier_code,
    origin_airport,

    count(*)                                          as scheduled_flights,
    count_if(is_cancelled)                            as cancelled_flights,
    count_if(is_departed)                             as departed_flights,
    count_if(is_departed and dep_delay_minutes < 15)  as departed_on_time_flights,
    count_if(is_operated)                             as operated_flights,
    count_if(is_on_time)                              as on_time_flights

from {{ ref('fct_flights') }}
group by flight_date, carrier_code, origin_airport
