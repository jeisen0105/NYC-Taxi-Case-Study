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
  
  -- Original total_amount is kept for reference
  total_amount AS original_total_amount,
  
  -- **RECALCULATE THE TOTAL AMOUNT** (Corrects the 10M row issue)
  (
    fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee
  ) AS calculated_total_amount,
  
  -- Calculate trip duration for analysis
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) AS trip_duration_minutes,

  -- **NEW CALCULATION: REVENUE PER MINUTE (RPM)**
  (
    fare_amount + extra + mta_tax + tip_amount + tolls_amount + improvement_surcharge + congestion_surcharge + Airport_fee
  ) / NULLIF(TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE), 0) AS revenue_per_minute
  
FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
  -- 1. Date and Time Cleaning
  TIMESTAMP_DIFF(tpep_dropoff_datetime, tpep_pickup_datetime, MINUTE) BETWEEN 1 AND 240 -- Duration 1 minute to 4 hours
  AND tpep_dropoff_datetime > tpep_pickup_datetime -- Dropoff must be after pickup
  AND EXTRACT(YEAR FROM tpep_pickup_datetime) = 2024
  
  -- 2. Vendor and Flag Cleaning
  AND VendorID IN (1, 2)
  AND store_and_fwd_flag IN ('Y', 'N')
  
  -- 3. Financial and Distance Cleaning
  AND trip_distance > 0 -- Must have moved
  AND fare_amount > 0 -- Must have a positive fare
  AND extra >= 0
  AND mta_tax >= 0
  AND tip_amount >= 0
  AND tolls_amount >= 0
  AND improvement_surcharge >= 0
  
  -- 4. Surcharge and Fee Validation (Assumes $0.00 and the standard fee are the only valid amounts)
  AND congestion_surcharge IN (0.00, 2.50)
  AND Airport_fee IN (0.00, 1.25)
  
  -- 5. Passenger and Code Cleaning
  AND passenger_count BETWEEN 1 AND 6 -- Increased to 6 for standard van/cab capacity
  AND RateCodeID IN (1, 2, 3, 4, 5, 6) -- Included all standard rate codes
  AND payment_type IN (1, 2) -- Only Credit (1) or Cash (2)
  
  -- 6. Location Cleaning
  AND PULocationID BETWEEN 1 AND 263
  AND DOLocationID BETWEEN 1 AND 263
  
  -- 7. Fare/Distance Sanity Check (Optional, but highly recommended)
  -- Ensures the average cost is at least $1.00 per mile, filtering extreme distance logging errors.
  AND fare_amount / trip_distance > 1.00
