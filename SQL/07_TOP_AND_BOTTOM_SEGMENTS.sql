/*
  ANALYSIS FILE: 07_TOP_AND_BOTTOM_SEGMENTS.sql
  Purpose: Creates two prioritized lists:
           1. TOP 10 (The Cash Cows): High-earning segments for the surcharge.
           2. BOTTOM 10 (The Cold Spots): Low-earning segments for the AI Pilot.
*/

-- ### PART A: THE TOP 10 FUNDING SEGMENTS (High Efficiency) ###

SELECT
  -- Where and When: The Neighborhood and the Day of the week
  tpu.Zone AS pickup_zone,
  CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
      WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
  END AS day_name,
  
  -- Volume and Time: How many trips and how long did they last?
  COUNT(*) AS total_trips,
  ROUND(AVG(t.trip_duration_minutes), 2) AS avg_duration,
  
  -- The Efficiency Score: The Median RPM
  ROUND(APPROX_QUANTILES(t.operational_revenue_per_minute, 2)[OFFSET(1)], 2) AS median_rpm

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
JOIN
  `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu ON t.PULocationID = tpu.LocationID

WHERE
  -- Quality Filters
  t.trip_duration_minutes > 1.0 AND t.calculated_total_amount > 2.0 

GROUP BY 1, 2
HAVING 
  -- We only focus on high-volume segments (at least 100k trips per year)
  COUNT(*) >= 100000 
ORDER BY 
  median_rpm DESC -- Best performers first
LIMIT 10;

-- -----------------------------------------------------------------------

-- ### PART B: THE BOTTOM 10 FIX SEGMENTS (Low Efficiency) ###

SELECT
  tpu.Zone AS pickup_zone,
  CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
      WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday'
      WHEN 4 THEN 'Wednesday' WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday'
      WHEN 7 THEN 'Saturday'
  END AS day_name,
  
  COUNT(*) AS total_trips,
  ROUND(AVG(t.trip_duration_minutes), 2) AS avg_duration,
  
  ROUND(APPROX_QUANTILES(t.operational_revenue_per_minute, 2)[OFFSET(1)], 2) AS median_rpm

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
JOIN
  `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu ON t.PULocationID = tpu.LocationID

WHERE
  t.trip_duration_minutes > 1.0 AND t.calculated_total_amount > 2.0 

GROUP BY 1, 2
HAVING 
  COUNT(*) >= 100000 
ORDER BY 
  median_rpm ASC -- Worst performers first
LIMIT 10;
