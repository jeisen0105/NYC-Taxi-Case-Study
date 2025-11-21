CREATE OR REPLACE TABLE
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
AS
SELECT DISTINCT -- Use DISTINCT to remove any identical duplicate rows first
    *
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
    -- 1. Eliminate Zero/Negative Passenger Count
    passenger_count > 0

    -- 2. Eliminate Zero/Negative Distance Errors
    AND trip_distance > 0

    -- 3. Eliminate Temporal Errors (Dropoff must be after Pickup)
    AND tpep_dropoff_datetime > tpep_pickup_datetime

    -- 4. Eliminate Zero/Negative Fares 
    AND fare_amount > 2.50

    -- 5. Exclude Suspect Outliers 
    AND trip_distance < 100  -- Excludes extremely long, suspect trips
    AND fare_amount < 500    -- Excludes extremely high, suspect fares

    -- 6. Exclude dates not in 2024 
    AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024;
