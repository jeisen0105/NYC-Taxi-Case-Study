-------------------------------------------------------------------
-- OVERALL CITYWIDE AVERAGE RPH (UNSEGMENTED BASELINE)
-- Calculates the average RPH for all valid trips in the dataset.
-------------------------------------------------------------------
SELECT
    'Citywide' AS pickup_zone,      
    'All Hours' AS time_segment,
    
    -- Calculation: Total Earnings (Fare + Tip) / Total Driving Hours
    SUM(t.total_amount + t.tip_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS overall_avg_rph,
    
    COUNT(*) AS total_trips

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t

WHERE
    -- Data Quality Filters: Trips must be between 5 minutes and 180 minutes
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) BETWEEN 5 AND 180;

-----------------------------------------------------------------------
-- TOP 10 PEAK HOUR ZONES (Measuring Total Earnings: Fare + Tip)
-----------------------------------------------------------------------
SELECT
    -- Zone and Borough for identification
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,
    'Peak Hour (M-F Rush)' AS time_segment,

    -- Trip count for statistical confidence
    COUNT(*) AS total_trips,

    -- 1. PRIMARY KPI: Total Hourly Earnings (Fare + Tip)
    SUM(t.total_amount + t.tip_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_total_earnings_per_hour,

    -- 2. SECONDARY KPI: Total Earnings Per Mile (Fare + Tip)
    SUM(t.total_amount + t.tip_amount) / SUM(t.trip_distance) AS avg_total_earnings_per_mile,

    -- Contextual metrics
    AVG(t.trip_distance) AS avg_trip_distance_miles

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
ON t.PULocationID = taxi_zone_lookup.LocationID

-- Data Quality Filters: Trips must be between 5 minutes and 180 minutes
WHERE
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) BETWEEN 5 AND 180

    -- Time Segment Filters (Peak: M-F, 6-10 AM & 4-8 PM)
    AND EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6
    AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (6, 7, 8, 9, 16, 17, 18, 19)

GROUP BY
    1, 2, 3
HAVING
    -- Filter out zones with unrealistically high averages and total trips under 100 (Adjusted for tips)
    COUNT(*) > 10000
    AND avg_total_earnings_per_hour < 180
    AND avg_total_earnings_per_mile < 60
ORDER BY
    avg_total_earnings_per_hour DESC
LIMIT 10;

-----------------------------------------------------------------------
--  TOP 10 OFF-PEAK ZONES (Measuring Total Earnings: Fare + Tip)
-----------------------------------------------------------------------
SELECT
    -- Zone and Borough for identification
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,
    'Off-Peak' AS time_segment,

    -- Trip count for statistical confidence
    COUNT(*) AS total_trips,

    -- 1. PRIMARY KPI: Total Hourly Earnings (Fare + Tip)
    SUM(t.total_amount + t.tip_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_total_earnings_per_hour,

    -- 2. SECONDARY KPI: Total Earnings Per Mile (Fare + Tip)
    SUM(t.total_amount + t.tip_amount) / SUM(t.trip_distance) AS avg_total_earnings_per_mile,

    -- Contextual metrics
    AVG(t.trip_distance) AS avg_trip_distance_miles

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
ON t.PULocationID = taxi_zone_lookup.LocationID

WHERE
    -- Data Quality Filters: Trips must be between 5 minutes and 180 minutes
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) BETWEEN 5 AND 180

    -- Time Segment Filters (Corrected Off-Peak: Everything NOT Peak)
    AND NOT (
        -- Weekdays (Mon-Fri)
        EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6
        -- AND Expanded Rush Hours (6-10 AM and 4-8 PM)
        AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (6, 7, 8, 9, 16, 17, 18, 19)
    )

GROUP BY
    1, 2, 3
HAVING
    -- Filter out zones with unrealistically high averages and total trips under 100 (Adjusted for tips)
    COUNT(*) > 10000
    AND avg_total_earnings_per_hour < 180
    AND avg_total_earnings_per_mile < 60
ORDER BY
    avg_total_earnings_per_hour DESC
LIMIT 10;
