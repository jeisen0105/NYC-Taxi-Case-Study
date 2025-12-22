/*
  ANALYSIS FILE: 10_PILOT_REVENUE_BASELINE.sql
  Purpose: Identifies the 10 lowest-performing segments (Location + Day of Week) 
           by Revenue Per Minute (RPM) and calculates their total operational revenue.
           This serves as the baseline for the $113.7M revenue optimization pilot.
*/

SELECT
  -- Goal: Total potential revenue captured by these 10 segments (Excluding Tips)
  ROUND(SUM(t.fare_amount + t.extra + t.mta_tax + t.tolls_amount + t.improvement_surcharge + t.congestion_surcharge + t.airport_fee), 2) AS bottom_10_total_revenue

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
  
WHERE
  -- Filter 1: Target only the specific "Bottom 10" inefficient segments
  CONCAT(t.PULocationID, '-', EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)) IN (
      
      -- Subquery to identify the 10 worst segments based on Median RPM
      SELECT 
          CONCAT(PULocationID, '-', EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime))
      FROM `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`
      GROUP BY 1
      HAVING COUNT(*) >= 100000 -- Ensures statistical significance (Busy segments only)
      ORDER BY APPROX_QUANTILES(operational_revenue_per_minute, 2)[OFFSET(1)] ASC -- Sort by Lowest Median RPM
      LIMIT 10 
  )
  
  -- Filter 2: Operational Quality Control
  AND t.trip_duration_minutes > 1.0  -- Removes extreme outliers/meter errors
  AND t.calculated_total_amount > 2.0; -- Ensures we are looking at valid paid trips
