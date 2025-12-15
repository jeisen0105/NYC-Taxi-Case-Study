/*
 ANALYSIS FILE: 08_PHASE2_TOTAL_REVENUE.sql
 PURPOSE: Calculates the Total Recovered Revenue for the Phase 2 Full Scale-Up,
          based on a 5% speed/RPM increase on every trip in the entire network.
*/

SELECT
    -- Calculation: SUM [Trip Duration * Current RPM * 5% Increase Factor] for every trip
    SUM(
        t.trip_duration_minutes * t.revenue_per_minute * 0.05
    ) AS D_Total_Phase2_Recovered_Revenue
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t;
