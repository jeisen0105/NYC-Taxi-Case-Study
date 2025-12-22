/*
  ANALYSIS FILE: 04_ESTIMATED_ANNUAL_REVENUE_LOSS.sql
  Purpose: Quantifies the total revenue opportunity cost by calculating the dollar value 
           of underperformance relative to the $1.65 citywide operational benchmark.
*/
SELECT
    -- Total Fleet Revenue: Every dollar made by every trip in 2024.
    ROUND(SUM(t.calculated_total_amount), 2) AS Total_Fleet_Actual_Revenue,

    -- 2. Total Revenue Leakage: Only the "lost" money from trips below $1.65.
    ROUND(SUM(
        CASE 
            WHEN t.operational_revenue_per_minute < 1.65 
            THEN (1.65 - t.operational_revenue_per_minute) * t.trip_duration_minutes 
            ELSE 0 
        END
    ), 2) AS Total_Estimated_Annual_Revenue_Loss,

    -- 3. Leakage Percentage: Shows how "significant" the loss is relative to total size.
    ROUND(
        (SUM(CASE WHEN t.operational_revenue_per_minute < 1.65 THEN (1.65 - t.operational_revenue_per_minute) * t.trip_duration_minutes ELSE 0 END) / 
        SUM(t.calculated_total_amount)) * 100, 2
    ) AS Leakage_Percent_of_Total_Revenue

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t

WHERE
    t.trip_duration_minutes > 1.0 
    AND t.calculated_total_amount > 2.0;
