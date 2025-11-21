-----------------------------------------------------------------------
-- QUERY 1: TOP 10 PEAK HOUR ZONES 
-----------------------------------------------------------------------
SELECT
    -- Retrieve the pick up zone and borough names from the new lookup table
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,

    -- Define peak segment
    'Peak Hour (M-F Rush)' AS time_segment,

    -- Count the total number of trips and create column
    COUNT(*) AS total_trips,

    -- Calculate the core KPI: (Total Revenue) / (Total Duration in hours) to get the average dollar per hour and create column
    SUM(t.total_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_net_revenue_per_hour,

    -- Calculate the average trip distance in miles for context on trip length
    AVG(t.trip_distance) AS avg_trip_distance_miles

    -- Use the main trip data table aliased as ’t’ for readability
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t

-- Begin the process of combining the two tables
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
    
-- Combine the tables by matching the Pickup Location ID with the Zones Location ID
ON t.PULocationID = taxi_zone_lookup.LocationID

WHERE
    -- Filter out any trips lasting 5 minutes or less to prevent short trips from skewing the per hour rate
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) > 5
    -- Filter only for the peak days (Monday=2 to Friday=6)
    AND EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6 
             -- Also filter for only peak hours (7-9 AM or 4-6 PM)
        AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (7, 8, 9, 16, 17, 18)

-- Group by the Zone, Borough, and Time Segment (using column numbers 1, 2, 3)
GROUP BY
    1, 2, 3
-- Sort the final output by the highest revenue per hour first (descending)
ORDER BY
    avg_net_revenue_per_hour DESC
-- Restrict the output to the top 20 most profitable combinations
LIMIT 10;
-----------------------------------------------------------------------
-- QUERY 2: TOP 10 OFF-PEAK ZONES 
-----------------------------------------------------------------------
SELECT
    -- Retrieve the pick up zone and borough names from the new lookup table
    taxi_zone_lookup.Zone AS pickup_zone,
    taxi_zone_lookup.Borough AS pickup_borough,

    -- Define off-peak segment
    'Off-Peak' AS time_segment,

    -- Count the total number of trips and create column
    COUNT(*) AS total_trips,

    -- Calculate the core KPI: (Total Revenue) / (Total Duration in hours) to get the average dollar per hour and create column
    SUM(t.total_amount) / SUM(TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) / 60.0) AS avg_net_revenue_per_hour,

    -- Calculate the average trip distance in miles for context on trip length
    AVG(t.trip_distance) AS avg_trip_distance_miles

    -- Use the main trip data table aliased as ’t’ for readability
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` AS t

-- Begin the process of combining the two tables
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS taxi_zone_lookup
    
-- Combine the tables by matching the Pickup Location ID with the Zones Location ID
ON t.PULocationID = taxi_zone_lookup.LocationID

WHERE
    -- Filter out any trips lasting 5 minutes or less to prevent short trips from skewing the per hour rate
    TIMESTAMP_DIFF(t.tpep_dropoff_datetime, t.tpep_pickup_datetime, MINUTE) > 5
    -- Filter only for the peak days (Monday=2 to Friday=6)
    AND NOT EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime) BETWEEN 2 AND 6 
             -- Also filter for only peak hours (7-9 AM or 4-6 PM)
        AND EXTRACT(HOUR FROM t.tpep_pickup_datetime) IN (7, 8, 9, 16, 17, 18)

-- Group by the Zone, Borough, and Time Segment (using column numbers 1, 2, 3)
GROUP BY
    1, 2, 3
-- Sort the final output by the highest revenue per hour first (descending)
ORDER BY
    avg_net_revenue_per_hour DESC
-- Restrict the output to the top 20 most profitable combinations
LIMIT 10;
