/*
  ANALYSIS FILE: 01_DATA_CLEANING_AND_LOGIC.sql
  Purpose: Creates the foundational table by filtering for official NYC TLC codes,
           enforcing positive financial values, and validating surcharge amounts.
*/

CREATE OR REPLACE TABLE `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS

SELECT
  -- Standard trip info
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  VendorID,
  PULocationID,
  DOLocationID,
  trip_distance,
  fare_amount,
  tip_amount,

  -- Create 'calculated_total_amount' 
  -- We sum all parts manually to be 100% sure the total is accurate.
  (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee) AS calculated_total_amount,
  
  -- Create 'trip_duration_minutes'
  -- This calculates the actual time the passenger spent in the car.
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) AS trip_duration_minutes,

  -- Create 'operational_revenue_per_minute' (RPM)
  -- This is our "Efficiency Metric." We exclude tips because tips are optional.
  (fare_amount + extra + mta_tax + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee) 
  / 
  NULLIF(TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE), 0) AS operational_revenue_per_minute
  
FROM
  `nyc-taxi-478617.2024_data.yellow_tripdata_2024`

WHERE
  -- *** CATEGORICAL VALIDATION ***
  -- Only include official Vendors, Rate Codes, and Payment Types
  VendorID IN (1, 2)
  AND store_and_fwd_flag IN ('Y', 'N')
  AND RateCodeID IN (1, 2, 3, 4, 5, 6)
  AND payment_type IN (1, 2)
  AND passenger_count BETWEEN 1 AND 6

  -- *** FINANCIAL INTEGRITY (0 OR MORE) ***
  -- Ensures we don't include refunds or negative data entry errors
  AND fare_amount > 0 
  AND extra >= 0
  AND mta_tax >= 0
  AND tip_amount >= 0
  AND tolls_amount >= 0
  AND improvement_surcharge >= 0
  
  -- *** SURCHARGE INTEGRITY ***
  -- Only include official NYC fees (2.50 for congestion, 1.25 for airports)
  AND congestion_surcharge IN (0.00, 2.50)
  AND Airport_fee IN (0.00, 1.25)
  
  -- *** LOGICAL & TIME CLEANING ***
  -- Filters for trips in 2024, valid NYC zones, and removes GPS/Meter glitches
  AND TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) BETWEEN 1 AND 240 
  AND trip_distance > 0 
  AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024
  AND PULocationID BETWEEN 1 AND 263
  AND DOLocationID BETWEEN 1 AND 263
  AND fare_amount / trip_distance > 1.00;
