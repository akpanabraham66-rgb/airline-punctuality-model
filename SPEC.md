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
| Cancellation rate | (cancelled ÷ scheduled) | Scheduled = every flight in the source data. Diverted flights count as operated not cancelled. The cancellation reasons include carrier, weather, air traffic system and security.  |
| Delay minutes by cause | (minutes per cause, and share of total) | Operated flights arriving 15+ minutes late only, because BTS reports causes only for these. The five causes must add up to the flight's arrival delay.  |

## 6. Acceptance criteria
1. Row count in the warehouse equals the row count in the source files.
2. (Copy the other six from the project plan, in your own words.)

## 7. Out of scope and known limitations
- (Time zones, delay causes only for flights 15+ minutes late, US data rather than Finnair data.)
- (Historical review only, not a live operational tool.)
