/*
  ANALYSIS FILE: 02_CITYWIDE_METRICS.sql
  Purpose: Establishes the core financial and operational benchmarks for the entire dataset.
           The Citywide Median RPM is used as the defensible policy target ($1.89/min).
*/
SELECT
  -- *** PRIMARY BENCHMARK (Policy Target) ***
  -- Calculate the Citywide Median RPM using APPROX_QUANTILES.
  APPROX_QUANTILES(calculated_total_amount / trip_duration_minutes, 2)[OFFSET(1)] AS citywide_median_rpm,
  
  -- Calculate the traditional Mean RPM.
  AVG(calculated_total_amount / trip_duration_minutes) AS citywide_mean_rpm,

  -- *** CONTEXTUAL METRICS ***
  
  -- Total number of trips remaining after the initial cleaning
  COUNT(1) AS total_trips_analyzed,
  
  -- Average trip duration across the city
  AVG(trip_duration_minutes) AS average_trip_duration_minutes

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`;
