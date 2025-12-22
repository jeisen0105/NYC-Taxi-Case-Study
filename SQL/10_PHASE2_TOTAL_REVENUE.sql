/*
  ANALYSIS FILE: 10_PHASE2_TOTAL_REVENUE.sql
  Purpose: Estimates the massive financial impact of applying the 
           5% efficiency gain to every single trip in the network.
*/

SELECT
  -- THE NETWORK-WIDE RECOVERY
  -- Logic: [Trip Time] * [Current Efficiency] * [5% Improvement]
  ROUND(SUM(
      t.trip_duration_minutes * t.operational_revenue_per_minute * 0.05
  ), 2) AS total_phase2_recovered_revenue_usd

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t

WHERE 
  -- Safety check to ensure we only calculate for valid trips
  t.trip_duration_minutes > 0;
