/*
  QUERY: 09_TOTAL_OPERATIONAL_REVENUE.sql
  Purpose: Calculates the EXACT total revenue from all trips in the cleaned table,
           excluding the tip amount. 
*/

SELECT
    -- Sum of all trip components EXCLUDING tip_amount
    SUM(
        fare_amount + 
        extra + 
        mta_tax + 
        tolls_amount + 
        improvement_surcharge + 
        congestion_surcharge + 
        Airport_fee
    ) AS total_operational_revenue_usd,
    
    -- For comparison, you can also see the total amount of tips collected
    SUM(tip_amount) AS total_tip_revenue_usd,

    -- And the overall total gross revenue (including tips)
    SUM(calculated_total_amount) AS total_gross_revenue_usd
    
FROM
    -- Reference the final cleaned table
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`;
