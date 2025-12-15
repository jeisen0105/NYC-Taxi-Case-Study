/*
  ANALYSIS FILE: 06_TOP10_BOTTOM10_SEGMENTS.sql
  Purpose: Generates the two prioritized lists for the Phase 1 intervention strategy:
           1. TOP 10 FUNDING: Highest OPERATIONAL RPM segments (for Surcharge proposal).
           2. BOTTOM 10 FIX: Lowest OPERATIONAL RPM segments (for Intervention proposal).
*/

-- #######################################################################
-- ### QUERY 1: TOP 10 FUNDING SEGMENTS (ORDERED BY HIGHEST OPERATIONAL RPM) ###
-- #######################################################################
-- This list identifies the most profitable segments to model the Surcharge Revenue.

SELECT
    -- Geographic Identifier
    tpu.Zone AS pickup_zone,
    
    -- Temporal Identifier
    CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    
    -- Volume and Duration (CRITICAL for ROI CALCULATION)
    COUNT(1) AS total_trips_in_segment,
    AVG(t.trip_duration_minutes) AS average_trip_duration_minutes, 
    
    -- Efficiency Metric
    APPROX_QUANTILES(t.operational_revenue_per_minute, 2)[OFFSET(1)] AS median_operational_rpm_usd_per_min
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu
    ON t.PULocationID = tpu.LocationID
    
WHERE
    -- Use the final data integrity filters
    t.trip_duration_minutes > 1.0 
    AND t.calculated_total_amount > 2.0 

GROUP BY 1, 2
    
HAVING
    -- Ensure statistical significance and executive relevance.
    COUNT(1) >= 100000 
    
ORDER BY 
    median_operational_rpm_usd_per_min DESC -- Ranks highest RPM first
LIMIT 10;

-- #######################################################################
-- ### QUERY 2: BOTTOM 10 FIX SEGMENTS (ORDERED BY LOWEST OPERATIONAL RPM) ###
-- #######################################################################
-- This list identifies the most problematic segments to model the Recovery Value.

SELECT
    -- Geographic Identifier
    tpu.Zone AS pickup_zone,
    
    -- Temporal Identifier 
    CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END AS day_name,
    
    -- Volume and Duration (CRITICAL for ROI CALCULATION)
    COUNT(1) AS total_trips_in_segment,
    AVG(t.trip_duration_minutes) AS average_trip_duration_minutes, 
    
    -- Efficiency Metric
    APPROX_QUANTILES(t.operational_revenue_per_minute, 2)[OFFSET(1)] AS median_operational_rpm_usd_per_min
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu
    ON t.PULocationID = tpu.LocationID
    
WHERE
    -- Use the final data integrity filters
    t.trip_duration_minutes > 1.0 
    AND t.calculated_total_amount > 2.0 

GROUP BY 1, 2
    
HAVING
    -- Ensure statistical significance and executive relevance
    COUNT(1) >= 100000 
    
ORDER BY 
    median_operational_rpm_usd_per_min ASC -- Ranks lowest RPM first
LIMIT 10;
