/*
  ANALYSIS FILE: 02_ESTIMATED_ANNUAL_REVENUE_LOSS.sql
  Purpose: Compares total actual revenue against the "Lost Opportunity." 
           It tells us exactly how big the $113.7M hole is compared to the whole business.
*/

SELECT
  -- TOTAL FLEET REVENUE
  ROUND(SUM(t.calculated_total_amount), 2) AS total_actual_revenue,

  -- THE REVENUE LEAKAGE ($113.7M)
  -- Logic: IF the trip was slower than $1.65/min, THEN calculate the loss.
  ROUND(SUM(
      CASE 
          WHEN t.operational_revenue_per_minute < 1.65 
          THEN (1.65 - t.operational_revenue_per_minute) * t.trip_duration_minutes 
          ELSE 0 
      END
  ), 2) AS total_revenue_leakage,

  -- THE LEAKAGE PERCENTAGE
  ROUND(
      (SUM(CASE WHEN t.operational_revenue_per_minute < 1.65 THEN (1.65 - t.operational_revenue_per_minute) * t.trip_duration_minutes ELSE 0 END) 
      / 
      SUM(t.calculated_total_amount)) * 100, 2
  ) AS leakage_percent_of_total

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t

WHERE
  -- Standard cleaning to ensure we only count real, high-quality trips
  t.trip_duration_minutes > 1.0 
  AND t.calculated_total_amount > 2.0;
