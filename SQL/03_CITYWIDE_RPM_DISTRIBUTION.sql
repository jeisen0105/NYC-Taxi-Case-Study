/*
  ANALYSIS FILE: 03_CITYWIDE_RPM_DISTRIBUTION.sql
  Purpose: Groups trips into $0.10 "Buckets" (Bins). 
           This data is used to build a Histogram chart showing the fleet's efficiency.
*/

SELECT
  -- Create the "Buckets" (Binning Logic)
  CAST(TRUNC(t.operational_revenue_per_minute * 10) / 10.0 AS FLOAT64) AS RPM_Start_Bin,
  
  -- Count the Trips
  -- How many trips fell into this specific 10-cent bucket?
  COUNT(*) AS Total_Trips_in_Bin
  
FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
  
GROUP BY
  -- We group by the bucket name so we can see the count for each 10-cent range
  RPM_Start_Bin
  
HAVING
  -- Statistical Filter: Only show buckets with 100 or more trips.
  COUNT(*) >= 100

ORDER BY
  -- Sort from lowest to highest RPM so the chart reads correctly from left to right.
  RPM_Start_Bin ASC;
