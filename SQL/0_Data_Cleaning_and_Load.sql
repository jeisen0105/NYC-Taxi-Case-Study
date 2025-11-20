-- Count Zero/Negative Fares and Passengers
SELECT
    COUNTIF(fare_amount <= 2.50) AS zero_fares,
    COUNTIF(passenger_count <= 0) AS zero_passengers
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`;

-- Count Temporal and Zero Distance Errors
SELECT
    COUNTIF(tpep_dropoff_datetime <= tpep_pickup_datetime) AS invalid_time,
    COUNTIF(trip_distance <= 0) AS zero_distance
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`;

-- Count Exact Duplicates 
SELECT
    COUNT(*) - COUNT(DISTINCT tpep_pickup_datetime || tpep_dropoff_datetime || fare_amount) AS duplicate_count
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`;

-- Overwrite the table with clean, filtered and deduplicated data
CREATE OR REPLACE TABLE
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined` 
AS
SELECT DISTINCT
    * 
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
    -- Excludes dates not in 2024
    EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024 AND
    fare_amount > 2.50 AND  -- Excludes fares less than or equal to $2.50
    passenger_count > 0 AND -- Excludes zero/negative passengers
    trip_distance > 0 AND   -- Excludes zero/negative distance
    tpep_dropoff_datetime > tpep_pickup_datetime AND -- Excludes zero/negative duration trips
    trip_distance < 100 AND -- Excludes very long, suspect trips
    fare_amount < 500;      -- Excludes very high, suspect fares

-- Verify that all invalid counts are now 0
SELECT
    COUNT(*) AS total_invalid_rows
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
    fare_amount <= 2.50 OR
    passenger_count <= 0 OR
    trip_distance <= 0 OR
    tpep_dropoff_datetime <= tpep_pickup_datetime;
