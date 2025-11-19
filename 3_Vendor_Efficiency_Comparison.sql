SELECT
    -- Select the unique ID for the taxi technology vendor
    VendorID,
    -- Count the total number of trips associated with with each vendor and create column
    COUNT(*) AS total_trips,
    
    -- KPI 1 (Quality): Average Speed and create column
    AVG(trip_distance / (TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) / 60.0)) AS avg_speed_mph,
    
    -- Calculate KPI 2 (Profitability): Average Cost per Minute and create column
    AVG(total_amount / TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE)) AS avg_cost_per_minute

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
    -- Filter to only include trips longer than 5 minutes preventing short trips from skewing averages
    TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) > 5
    -- Ensure distance and duration are positive to avoid division by zero errors in calculations
    AND (trip_distance > 0 AND TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) > 0) 
GROUP BY
    VendorID
ORDER BY
    avg_speed_mph DESC;
