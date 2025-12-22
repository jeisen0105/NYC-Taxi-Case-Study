/*
  ANALYSIS FILE: 01_DATA_CLEANING_AND_LOGIC.sql
  Purpose: Creates the foundational table by filtering for official NYC TLC codes,
           enforcing positive financial values, and validating surcharge amounts.
           This version preserves ALL relevant original columns for audit transparency.
*/

CREATE OR REPLACE TABLE `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS

SELECT
  -- 1. KEEP ALL ORIGINAL COLUMNS (The Source Data)
  VendorID,
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  passenger_count,
  trip_distance,
  RatecodeID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  payment_type,
  fare_amount,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge,
  total_amount, 
  congestion_surcharge,
  airport_fee,

  -- CREATE CALCULATED METRICS (The Analysis Data)
  
  -- Create 'calculated_total_amount' 
  -- We sum all parts manually to ensure 100% accuracy.
  (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + 
   congestion_surcharge + airport_fee) AS calculated_total_amount,
  
  -- Create 'trip_duration_minutes'
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) AS trip_duration_minutes,

  -- Create 'operational_revenue_per_minute' (RPM)
  -- This is our "Efficiency Metric." We exclude tips because they are optional.
  (fare_amount + extra + mta_tax + tolls_amount + improvement_surcharge + 
   congestion_surcharge + airport_fee) 
  / 
  NULLIF(TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE), 0) AS operational_revenue_per_minute
  
FROM
  `nyc-taxi-478617.2024_data.yellow_tripdata_2024`

WHERE
  -- *** CATEGORICAL VALIDATION ***
  VendorID IN (1, 2)
  AND RatecodeID IN (1, 2, 3, 4, 5, 6)
  AND payment_type IN (1, 2)
  AND passenger_count BETWEEN 1 AND 6

  -- *** FINANCIAL INTEGRITY ***
  AND fare_amount > 0 
  AND extra >= 0
  AND mta_tax >= 0
  AND tip_amount >= 0
  AND tolls_amount >= 0
  AND improvement_surcharge >= 0
  
  -- *** SURCHARGE INTEGRITY ***
  AND congestion_surcharge IN (0.00, 2.50)
  AND airport_fee IN (0.00, 1.25)
  
  -- *** LOGICAL & TIME CLEANING ***
  AND TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) BETWEEN 1 AND 240 
  AND trip_distance > 0 
  AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024
  AND PULocationID BETWEEN 1 AND 263
  AND DOLocationID BETWEEN 1 AND 263
  AND fare_amount / trip_distance > 1.00;
