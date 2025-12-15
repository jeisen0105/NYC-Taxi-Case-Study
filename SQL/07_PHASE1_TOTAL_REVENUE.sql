/*
  ANALYSIS FILE: 07_PHASE1_TOTAL_REVENUE.sql
  PURPOSE: Calculates the Total Project Revenue (A + B) for the Phase 1 Pilot.
*/

WITH Surcharge_Revenue AS (
    -- Calculates the funding mechanism (A)
    SELECT
        -- Surcharge Revenue: Total trips * $0.99 Surcharge * 85% Retention Factor ($0.8415)
        SUM(t.total_trips_in_segment * 0.8415) AS A_Total_Surcharge_Revenue
    FROM
        `nyc-taxi-478617.2024_data.top_10_segments_roi` AS t
),

Recovered_Revenue AS (
    -- Calculates the profit mechanism (B) - Note: This section remains unchanged.
    SELECT
        SUM(
            b.average_trip_duration_minutes * b.total_trips_in_segment * b.median_operational_rpm_usd_per_min * 0.05
        ) AS B_Total_Recovered_Revenue
    FROM
        `nyc-taxi-478617.2024_data.bottom_10_segments_roi` AS b
)

-- Combines A and B to get the Total Project Revenue (C)
SELECT
    S.A_Total_Surcharge_Revenue,
    R.B_Total_Recovered_Revenue,
    (S.A_Total_Surcharge_Revenue + R.B_Total_Recovered_Revenue) AS C_Total_Project_Revenue
FROM
    Surcharge_Revenue AS S, Recovered_Revenue AS R;
