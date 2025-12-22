/*
  QUERY: 05_TOTAL_OPERATIONAL_REVENUE.sql
  Purpose: Calculates the EXACT total revenue from all trips in the cleaned table,
           specifically separating Operational (Business) revenue from Tips. 
*/

SELECT
    -- Total Operational Revenue
    -- Sum of all business-related components EXCLUDING tip_amount.
    ROUND(SUM(
        fare_amount + 
        extra + 
        mta_tax + 
        tolls_amount + 
        improvement_surcharge + 
        congestion_surcharge + 
        airport_fee
    ), 2) AS total_operational_revenue_usd,
    
    -- Total Tip Revenue
    -- For comparison, this shows the total gratuity earned by drivers.
    ROUND(SUM(tip_amount), 2) AS total_tip_revenue_usd,

    -- Total Gross Revenue
    -- The absolute total of all money collected (Operational + Tips).
    ROUND(SUM(calculated_total_amount), 2) AS total_gross_revenue_usd
    
FROM
    -- Reference the final cleaned table
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned`;
