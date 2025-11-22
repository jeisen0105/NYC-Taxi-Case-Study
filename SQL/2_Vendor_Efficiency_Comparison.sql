SELECT
    -- 1. Enhance Readability: Decode VendorID for clear presentation
    CASE t.VendorID
        WHEN 1 THEN 'Creative Mobile Technologies (CMT)'
        WHEN 2 THEN 'VeriFone (VTS)'
        ELSE 'Other/Unknown'
    END AS vendor_name,

    -- Count the total number of trips associated with each vendor
    COUNT(*) AS total_trips,

    -- 2. PRIMARY KPI: Total Earnings Per Hour (Fare + Tip)
    SUM(t.total_amount + t.tip_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_total_earnings_per_hour,

    -- SECONDARY KPI: Average Speed (Quality/Efficiency Check)
    AVG(t.trip_distance / (TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0)) AS avg_speed_mph,

    -- Contextual Metric: Average Trip Distance
    AVG(t.trip_distance) AS avg_trip_distance_miles

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t
WHERE
    -- Use the established duration filters for high-quality analysis
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) BETWEEN 5 AND 180
    -- Ensure positive distance and duration (covered by your existing cleaning)
    AND t.trip_distance > 0
    -- Ensure positive total revenue (Fare + Tip) for accurate KPI calculation
    AND (t.total_amount + t.tip_amount) > 0
    
GROUP BY
    1
ORDER BY
    -- Rank the vendors by the most important KPI: Total Earnings Per Hour
    avg_total_earnings_per_hour DESC;
