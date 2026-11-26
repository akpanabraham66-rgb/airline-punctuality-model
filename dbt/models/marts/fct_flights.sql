-- fct_flights: one row per scheduled flight (the grain).
-- The measurements and flags come from stg_flights unchanged. This model adds
-- the flight key and keeps the codes that join to the dimensions.

select
    -- Flight key from acceptance criterion 2: date, airline, flight number, origin.
    -- For example 2025-06-01-DL-1234-ATL.
    flight_date || '-' || carrier_code || '-' || flight_number || '-' || origin_airport
                                    as flight_key,

    -- Codes that join to the dimensions
    flight_date,                    -- dim_date
    carrier_code,                   -- dim_carrier
    origin_airport,                 -- dim_airport
    dest_airport,                   -- dim_airport

    -- Other identifiers
    flight_number,
    tail_number,
    scheduled_dep_hhmm,

    -- Status flags (defined once, in stg_flights)
    is_cancelled,
    cancellation_code,
    is_diverted,
    is_departed,
    is_operated,
    is_on_time,

    -- Measurements in minutes
    dep_delay_minutes,
    arr_delay_minutes,
    carrier_delay_minutes,
    weather_delay_minutes,
    nas_delay_minutes,
    security_delay_minutes,
    late_aircraft_delay_minutes

from {{ ref('stg_flights') }}
