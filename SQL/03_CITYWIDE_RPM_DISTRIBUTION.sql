/*
  ANALYSIS FILE: 03_CITYWIDE_RPM_DISTRIBUTION.sql
  Purpose: Generates the aggregated data necessary to plot the Citywide RPM Histogram.
           This visualization is critical for showing *where* the bulk of trip volume
           falls relative to the $1.89 policy target.
*/
WITH Citywide_Aggregates AS (
    -- 1. Calculate the Median and Mean for the entire dataset once.
    SELECT
        APPROX_QUANTILES(t.calculated_total_amount / t.trip_duration_minutes, 2)[OFFSET(1)] AS Citywide_Median_RPM,
        AVG(t.calculated_total_amount / t.trip_duration_minutes) AS Citywide_Mean_RPM
    FROM
        `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
),
Single_Trip_Metrics AS (
    -- 2. Calculate the RPM and the Bin for every trip.
    SELECT
        (t.calculated_total_amount / t.trip_duration_minutes) AS Trip_RPM,
        CAST(TRUNC((t.calculated_total_amount / t.trip_duration_minutes) * 10) / 10.0 AS FLOAT64) AS RPM_Start_Bin,
        1 AS Trip_Count
    FROM
        `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
)

SELECT
    -- 3. Group the bins and join the citywide aggregates.
    t.RPM_Start_Bin, 
    SUM(t.Trip_Count) AS Total_Trips_in_Bin,
    
    -- Join the single-row Citywide_Aggregates to every resulting row
    a.Citywide_Median_RPM,
    a.Citywide_Mean_RPM

FROM
    Single_Trip_Metrics AS t
CROSS JOIN
    Citywide_Aggregates AS a
    
-- ************************************************************
-- ADDED FILTER: Ensures the histogram only goes up to the 4.9 bin
-- ************************************************************
WHERE
    t.RPM_Start_Bin <= 4.9
    
GROUP BY
    t.RPM_Start_Bin, a.Citywide_Median_RPM, a.Citywide_Mean_RPM
    
HAVING
    SUM(t.Trip_Count) >= 100 

ORDER BY
    t.RPM_Start_Bin ASC;
