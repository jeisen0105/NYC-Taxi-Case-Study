/*
  ANALYSIS FILE: 04_ESTIMATED_ANNUAL_REVENUE_LOSS.sql
  Purpose: Quantifies the total revenue opportunity cost by calculating the dollar value 
           of underperformance relative to the $1.65 citywide operational benchmark.
*/
SELECT
    -- Total Estimated Loss: Sums the financial gap across all underperforming trips.
    SUM(
        -- Calculation: (Target RPM - Actual Operational RPM) * Trip Duration (Minutes)
        (1.65 - t.operational_revenue_per_minute) * t.trip_duration_minutes
    ) AS Total_Estimated_Annual_Revenue_Loss
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t

WHERE
    -- Filter 1: Exclude noise using basic sanity checks.
    t.trip_duration_minutes > 1.0 
    AND t.calculated_total_amount > 2.0 
    
    -- Filter 2: Only include trips that are performing BELOW the $1.65 target.
    AND t.operational_revenue_per_minute < 1.65;
