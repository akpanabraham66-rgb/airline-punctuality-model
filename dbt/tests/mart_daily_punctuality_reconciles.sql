-- Reconciliation test: the mart's totals must equal the counts in fct_flights,
-- so no flight is lost or double-counted by the GROUP BY.
-- Returns one row (a failure) if any total differs.

with mart as (

    select
        sum(scheduled_flights)  as mart_scheduled,
        sum(cancelled_flights)  as mart_cancelled,
        sum(departed_flights)   as mart_departed,
        sum(operated_flights)   as mart_operated,
        sum(on_time_flights)    as mart_on_time
    from {{ ref('mart_daily_punctuality') }}

),

fact as (

    select
        count(*)                as fact_scheduled,
        count_if(is_cancelled)  as fact_cancelled,
        count_if(is_departed)   as fact_departed,
        count_if(is_operated)   as fact_operated,
        count_if(is_on_time)    as fact_on_time
    from {{ ref('fct_flights') }}

)

select *
from mart cross join fact
where mart_scheduled <> fact_scheduled
   or mart_cancelled <> fact_cancelled
   or mart_departed  <> fact_departed
   or mart_operated  <> fact_operated
   or mart_on_time   <> fact_on_time
