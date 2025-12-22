/*
  ANALYSIS FILE: 11_PILOT_REVENUE_BASELINE.sql
  Purpose: Finds the 10 worst segments and sums their total money.
*/

SELECT
  -- Final Goal: The total money made by these 10 segments (Minus Tips)
  ROUND(SUM(t.calculated_total_amount - t.tip_amount), 2) AS bottom_10_total_revenue

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t

WHERE
  -- Filter 1: Only look at trips that belong to our "Bottom 10" segments
  CONCAT(t.PULocationID, '-', EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)) IN (
      
      -- This inner part just makes the "List" of the 10 worst segments
      SELECT 
          CONCAT(PULocationID, '-', EXTRACT(DAYOFWEEK FROM tpep_pickup_datetime))
      FROM `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`
      GROUP BY 1
      HAVING COUNT(*) >= 100000 -- Only look at busy areas
      ORDER BY APPROX_QUANTILES(operational_revenue_per_minute, 2)[OFFSET(1)] ASC -- Lowest RPM first
      LIMIT 10 -- Take the bottom 10
  )
  
  -- Filter 2: Basic cleaning to make sure the data is high quality
  AND t.trip_duration_minutes > 1.0 
  AND t.calculated_total_amount > 2.0;
