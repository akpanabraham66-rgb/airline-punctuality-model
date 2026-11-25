-- stg_flights: one row per scheduled flight, cleaned and typed.
-- Renames the BTS columns, converts text to dates and numbers once,
-- and adds the flags every later model uses. Nothing downstream reads RAW directly.

with source as (

    select * from {{ source('raw', 'flights') }}

),

typed as (

    select
        -- Identifiers
        try_to_date(split_part(fl_date, ' ', 1), 'MM/DD/YYYY')  as flight_date,
        op_unique_carrier                                       as carrier_code,
        op_carrier_fl_num                                       as flight_number,
        tail_num                                                as tail_number,
        origin                                                  as origin_airport,
        dest                                                    as dest_airport,

        -- Scheduled departure, local time, hhmm text such as '0829'.
        -- Kept as text so the leading zero survives.
        crs_dep_time                                            as scheduled_dep_hhmm,

        -- Delays in minutes (negative means early)
        dep_delay::float                                        as dep_delay_minutes,
        arr_delay::float                                        as arr_delay_minutes,

        -- Status: BTS sends 0.00 or 1.00 as text, so compare the number to 1
        cancelled::float = 1                                    as is_cancelled,
        cancellation_code,
        diverted::float = 1                                     as is_diverted,

        -- Delay causes in minutes, only filled for flights arriving 15+ minutes late
        carrier_delay::float                                    as carrier_delay_minutes,
        weather_delay::float                                    as weather_delay_minutes,
        nas_delay::float                                        as nas_delay_minutes,
        security_delay::float                                   as security_delay_minutes,
        late_aircraft_delay::float                              as late_aircraft_delay_minutes

    from source

),

flagged as (

    select
        *,
        -- Flight status flags, as defined in SPEC.md section 4.
        -- Each group sits inside the one before: departed, then operated, then on time.
        not is_cancelled                         as is_departed,
        not is_diverted and not is_cancelled     as is_operated,
        is_operated and arr_delay_minutes < 15   as is_on_time

    from typed

)

select * from flagged
