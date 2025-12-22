/*
  ANALYSIS FILE: 02_CITYWIDE_METRICS.sql
  Purpose: Finds the "Gold Standard" performance metrics for the whole fleet.
           The Median RPM (approx. $1.65) is our target for an efficient trip.
*/

SELECT
  -- THE GOLD STANDARD (Median RPM)
  -- This is the "Benchmark" we use to find the $113.7M revenue leakage.
  APPROX_QUANTILES(operational_revenue_per_minute, 2)[OFFSET(1)] AS citywide_median_operational_rpm,
  
  -- THE AVERAGE RPM (Mean)
  AVG(operational_revenue_per_minute) AS citywide_mean_operational_rpm,

  -- THE GROSS RPM (Includes Tips)
  AVG(calculated_total_amount / trip_duration_minutes) AS citywide_mean_gross_rpm,

  -- TOTAL FLEET VOLUME
  COUNT(*) AS total_trips_analyzed,
  
  -- AVERAGE TRIP TIME
  AVG(trip_duration_minutes) AS average_trip_duration_minutes

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`;
