-- dim_date: one row per date (the grain), June to August 2025,
-- with the calendar columns Power BI slices by.

select distinct
    flight_date,
    year(flight_date)                    as year,
    month(flight_date)                   as month_number,   -- 6, 7, 8
    monthname(flight_date)               as month_name,     -- Jun, Jul, Aug
    to_char(flight_date, 'YYYY-MM')      as year_month,     -- 2025-06
    dayofweekiso(flight_date)            as weekday_number, -- 1 = Monday ... 7 = Sunday
    dayname(flight_date)                 as weekday_name,   -- Mon, Tue ...
    dayofweekiso(flight_date) in (6, 7)  as is_weekend

from {{ ref('stg_flights') }}
