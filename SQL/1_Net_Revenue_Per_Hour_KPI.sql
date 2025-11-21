-----------------------------------------------------------------------
-- QUERY 1: TOP 10 PEAK HOUR ZONES 
-----------------------------------------------------------------------
SELECT
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,
    'Peak Hour (M-F Rush)' AS time_segment,
    COUNT(*) AS total_trips,
    SUM(t.total_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_net_revenue_per_hour,
    SUM(t.total_amount) / SUM(t.trip_distance) AS avg_net_revenue_per_mile,
    AVG(t.trip_distance) AS avg_trip_distance_miles
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
ON t.PULocationID = taxi_zone_lookup.LocationID
WHERE
    -- Data Quality Filters: Trips must be between 5 minutes and 180 minutes
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) > 5
    AND TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) < 180
    -- Time Segment Filters (Peak)
    AND EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6
    AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (6, 7, 8, 9, 16, 17, 18, 19)
GROUP BY
    1, 2, 3
HAVING
    avg_net_revenue_per_hour < 150
    AND avg_net_revenue_per_mile < 50
ORDER BY
    avg_net_revenue_per_hour DESC
LIMIT 10;
-----------------------------------------------------------------------
-- QUERY 2: TOP 10 OFF-PEAK ZONES 
-----------------------------------------------------------------------
SELECT
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,
    'Off-Peak' AS time_segment,
    COUNT(*) AS total_trips,
    SUM(t.total_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_net_revenue_per_hour,
    SUM(t.total_amount) / SUM(t.trip_distance) AS avg_net_revenue_per_mile,
    AVG(t.trip_distance) AS avg_trip_distance_miles
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
ON t.PULocationID = taxi_zone_lookup.LocationID
WHERE
    -- Data Quality Filters: Trips must be between 5 minutes and 180 minutes
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) > 5
    AND TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) < 180
    -- Time Segment Filters (Corrected Off-Peak)
    AND NOT (
        EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6
        AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (6, 7, 8, 9, 16, 17, 18, 19)
    )
GROUP BY
    1, 2, 3
HAVING
    avg_net_revenue_per_hour < 150
    AND avg_net_revenue_per_mile < 50
ORDER BY
    avg_net_revenue_per_hour DESC
LIMIT 10;
