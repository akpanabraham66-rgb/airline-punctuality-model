# Airline Operations Punctuality Model: Business Specification

**Author:** Abraham Akpan  |  **Version:** 0.1  |  **Date:** 28 October 2026

## 1. Purpose
(Two sentences: who uses this, and what decision it helps them make.)

## 2. User and questions
- **User:** (role, and how often they look at it)
- **Questions it must answer:**
  1. (How punctual was the operation last week?)
  2. (Where does delay start: which airports, airlines, times of day?)
  3. (How much delay passes from one flight to the next on the same aircraft?)

## 3. Data source
- US Department of Transportation (BTS) Reporting Carrier On-Time Performance, June to August 2025.
- One row per scheduled US domestic flight.

## 4. Definitions
| Term | Definition |
|---|---|
| Scheduled flight | Every flight in the BTS data for June to August 2025, whether it operated, was cancelled or was diverted. |
| Operated flight | A scheduled flight that flew and landed at its planned destination: not cancelled or diverted. |
| On time | An operated flight that arrive less than 15 minutes after its scheduled arrival time. Early arrival count as on time. |
| First flight of the day | For each. aircraft (tail number) on each date, its earliest operated departure. If the first scheduled flight was cancelled, the next operated flight counts. |

## 5. KPIs and business rules
| KPI | Formula | Rules and exclusions |
|---|---|---|
| Arrival on-time performance (A15) | aircrafts that arrive less than 15 minutes of its scheduled time and airline that flies the plane, provides the crew and services |
| First-wave departure punctuality | first-wave flights that departed less than 15 minutes late ÷ all operated first-wave flights) | (an airlines aircraft earliest scheduled departure on any date |
| Reactionary delay share | (late-aircraft minutes ÷ all delay-cause minutes) | use the late-aircraft delay minutes that airline report to BTS (the LateAircraftDelay column). Calculate the share only over operated flights that arrived 15 minutes or more late.   |
| Cancellation rate | cancelled ÷ scheduled | No exclusions: the denominator is every scheduled flight. Diverted flights are not cancelled, so they count in the  The cancellation reasons include carrier, weather, air traffic system and security.  |
| Delay minutes by cause | (minutes per cause, and share of total) | Operated flights arriving 15+ minutes late only, because BTS reports causes only for these. |

## 6. Acceptance criteria
| 1. Raw row count in Snowflake equals the total number of row in the source files |
| 2. The flight key (date, airline, flight number, origin) is unique in fct_flights. If it is not, document the duplicates |
| 3. Date, airline, origin and destination are never empty |
| 4. Cancelled is always 0 or 1. CancellationCode is A, B, C or D whenever a flight is cancelled |
| 5. Every origin and destination exists in dim_airport, and every airline exists in dim_carrier |
| 6. For flights arriving 15 or more minutes late, the five delay-cause minutes add up to the arrival delay |
| 7. Power BI's monthly A15 matches the SQL result to within 0.1 percentage points |

## 7. Out of scope and known limitations
| All times are local to each airport: departures in the origin's time zone and arrivals in the destination's, with no adjustment. This means times cannot be compared as one clock across airports, and flight durations cannot be calculated by subtracting departure from arrival. | BTS only reports delay causes for flights arriving 15 or more minutes late, so the reactionary share describes significant delays only| The data covers domestic flights by US airlines that report to BTS, such as Delta and American, not Finnair, so the result cannot be compared with Finnair's punctuality. The definitions and model would work the same way on Finnair's own flight data, with only the delay-cause mapping changed | A breakdown by time of day is out of scope for this version |
| Historical review of June to August 2025, loaded once with no refresh. This means it shows patterns after the event and cannot support decisions on the day of operation. Running it as a weekly review would need a scheduled data load and dbt job. | Summer months only, so results may not hold for winter, when snow, de-icing and shorter days change the delay patterns |
