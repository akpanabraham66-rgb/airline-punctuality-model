USE WAREHOUSE PUNCTUALITY_WH;
USE SCHEMA PUNCTUALITY.RAW;

SELECT
  COUNT(*)                                             AS scheduled,
  COUNT_IF(CANCELLED::FLOAT = 1)                       AS cancelled,
  COUNT_IF(DIVERTED::FLOAT = 1)                        AS diverted,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0) AS operated,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0
           AND ARR_DELAY IS NULL)                      AS operated_no_arr_delay
FROM FLIGHTS;

SELECT
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0)                          AS operated_flights,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0 AND ARR_DELAY::FLOAT < 15) AS on_time_flights,
  ROUND(100 * on_time_flights / operated_flights, 1)                               AS a15_pct
FROM FLIGHTS;

-- By month: the reference numbers for criterion 7
SELECT
  SPLIT_PART(FL_DATE, '/', 1)                                                      AS month,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0)                          AS operated_flights,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0 AND ARR_DELAY::FLOAT < 15) AS on_time_flights,
  ROUND(100 * on_time_flights / operated_flights, 1)                               AS a15_pct
FROM FLIGHTS
GROUP BY month
ORDER BY month;

-- By airline: best to worst
SELECT
  OP_UNIQUE_CARRIER                                                                AS airline,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0)                          AS operated_flights,
  COUNT_IF(CANCELLED::FLOAT = 0 AND DIVERTED::FLOAT = 0 AND ARR_DELAY::FLOAT < 15) AS on_time_flights,
  ROUND(100 * on_time_flights / operated_flights, 1)                               AS a15_pct
FROM FLIGHTS
GROUP BY airline
ORDER BY a15_pct DESC;

SELECT
  COUNT(*)                                     AS scheduled_flights,
  COUNT_IF(CANCELLED::FLOAT = 1)               AS cancelled_flights,
  ROUND(100 * cancelled_flights / scheduled_flights, 2) AS cancellation_rate_pct
FROM FLIGHTS;

SELECT CANCELLATION_CODE, COUNT(*) AS cancelled_flights
FROM FLIGHTS
WHERE CANCELLED::FLOAT = 1
GROUP BY CANCELLATION_CODE
ORDER BY cancelled_flights DESC;

SELECT
  SUM(LATE_AIRCRAFT_DELAY::FLOAT)                       AS late_aircraft_minutes,
  SUM(CARRIER_DELAY::FLOAT) + SUM(WEATHER_DELAY::FLOAT) + SUM(NAS_DELAY::FLOAT)
    + SUM(SECURITY_DELAY::FLOAT) + SUM(LATE_AIRCRAFT_DELAY::FLOAT) AS all_cause_minutes,
  ROUND(100 * late_aircraft_minutes / all_cause_minutes, 1) AS reactionary_share_pct
FROM FLIGHTS
WHERE CANCELLED::FLOAT = 0
  AND DIVERTED::FLOAT = 0
  AND ARR_DELAY::FLOAT >= 15;

  -- Delay minutes by cause (the spec's fifth KPI)
SELECT
  SUM(CARRIER_DELAY::FLOAT) + SUM(WEATHER_DELAY::FLOAT) + SUM(NAS_DELAY::FLOAT)
    + SUM(SECURITY_DELAY::FLOAT) + SUM(LATE_AIRCRAFT_DELAY::FLOAT) AS all_cause_minutes,
  ROUND(100 * SUM(CARRIER_DELAY::FLOAT)       / all_cause_minutes, 1) AS carrier_pct,
  ROUND(100 * SUM(WEATHER_DELAY::FLOAT)       / all_cause_minutes, 1) AS weather_pct,
  ROUND(100 * SUM(NAS_DELAY::FLOAT)           / all_cause_minutes, 1) AS nas_pct,
  ROUND(100 * SUM(SECURITY_DELAY::FLOAT)      / all_cause_minutes, 1) AS security_pct,
  ROUND(100 * SUM(LATE_AIRCRAFT_DELAY::FLOAT) / all_cause_minutes, 1) AS late_aircraft_pct
FROM FLIGHTS
WHERE CANCELLED::FLOAT = 0
  AND DIVERTED::FLOAT = 0
  AND ARR_DELAY::FLOAT >= 15;
