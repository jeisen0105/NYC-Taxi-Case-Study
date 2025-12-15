/*
  ANALYSIS FILE: 03_CITYWIDE_RPM_DISTRIBUTION.sql
  Purpose: Groups trips into $0.10 RPM bins to create the Histogram visualization 
*/
SELECT
    -- Binning Logic: Truncates the OPERATIONAL RPM to one decimal place to create $0.10 buckets.
    CAST(TRUNC(t.operational_revenue_per_minute * 10) / 10.0 AS FLOAT64) AS RPM_Start_Bin,
    
    -- Count the total number of trips falling into each bin.
    COUNT(1) AS Total_Trips_in_Bin
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
    
GROUP BY
    RPM_Start_Bin -- Groups all trips that fell into the same $0.10 bin.
    
HAVING
    COUNT(1) >= 100 -- Removes bins with very low trip counts to focus on main distribution.

ORDER BY
    RPM_Start_Bin ASC;
