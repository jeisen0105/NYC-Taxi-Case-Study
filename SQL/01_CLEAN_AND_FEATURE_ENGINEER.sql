/*
  DATA CLEANING AND FEATURE ENGINEERING: YELLOW CAB 2024 TRIPS
  Purpose: Creates the clean, foundation table for operational efficiency analysis 
           by filtering statistical noise and correcting financial integrity issues.
*/
CREATE OR REPLACE TABLE
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`
AS
SELECT
  tpep_pickup_datetime,
  tpep_dropoff_datetime,
  VendorID,
  store_and_fwd_flag,
  PULocationID,
  DOLocationID,
  passenger_count,
  trip_distance,
  RateCodeID,
  payment_type, 
  fare_amount, 
  congestion_surcharge,
  Airport_fee,
  extra,
  mta_tax,
  tip_amount,
  tolls_amount,
  improvement_surcharge, 
  
  -- total_amount renamed and kept for reference.
  total_amount AS original_total_amount,

  -- *** FEATURE ENGINEERING: Core Metrics ***
  
  -- calculated_total_amount: Sum of components to correct errors in the original total_amount.
  (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee) AS calculated_total_amount,
  
  -- trip_duration_minutes: Calculates time in minutes, essential for RPM metric.
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) AS trip_duration_minutes,

  -- revenue_per_minute: The primary KPI for efficiency analysis.
  (fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee) / NULLIF(TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE), 0) AS revenue_per_minute
  
FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
  -- *** DATA CLEANING AND OUTLIER REMOVAL ***

  -- Date and time cleaning: Remove statistical outliers and logical errors.
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) BETWEEN 1 AND 240 
  AND tpep_dropoff_datetime > tpep_pickup_datetime 
  AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024
  
  -- Vendor and flag cleaning: Standardize vendor and flag values.
  AND VendorID IN (1, 2)
  AND store_and_fwd_flag IN ('Y', 'N')
  
  -- Financial and distance: Filter for commercially relevant, positive trips.
  AND trip_distance > 0 
  AND fare_amount > 0 
  AND extra >= 0
  AND mta_tax >= 0
  AND tip_amount >= 0
  AND tolls_amount >= 0
  AND improvement_surcharge >= 0
  
  -- Surcharge and fee validation cleaning: Validate fees against known standard rates. 
  AND congestion_surcharge IN (0.00, 2.50)
  AND Airport_fee IN (0.00, 1.25)
  
  -- Passenger, rate code and payment type cleaning: Limit to realistic capacities and codes.
  AND passenger_count BETWEEN 1 AND 6 
  AND RateCodeID IN (1, 2, 3, 4, 5, 6) 
  AND payment_type IN (1, 2) 
  
  -- Location cleaning: Ensures valid zone IDs (1-263).
  AND PULocationID BETWEEN 1 AND 263
  AND DOLocationID BETWEEN 1 AND 263
  
  -- Fare/distance sanity check: Filters extreme errors where distance was mislogged
  AND fare_amount / trip_distance > 1.00
