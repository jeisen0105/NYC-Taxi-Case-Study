/*
  ANALYSIS FILE: 10_BOTTOM10_EXACT_TOTAL_OPERATIONAL_REVENUE.sql
  Purpose: Calculates the EXACT total OPERATIONAL revenue (Gross Revenue MINUS Tips) 
           for all trips belonging to the 10 lowest-performing segments.
*/

-- Step 1: Identify the 10 segments (Pickup Zone + Day) with the lowest median operational RPM.
WITH Bottom10Segments AS (
    SELECT
        tpu.Zone AS pickup_zone,
        -- Convert the day-of-week number to a descriptive name for the segment identifier
        CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
            WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday' WHEN 4 THEN 'Wednesday' 
            WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday' WHEN 7 THEN 'Saturday'
        END AS day_name
    FROM
        -- Use the original cleaned data table
        `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
    JOIN
        `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu
        ON t.PULocationID = tpu.LocationID
    WHERE
        t.trip_duration_minutes > 1.0 
        AND t.calculated_total_amount > 2.0 
    GROUP BY 1, 2
    HAVING
        COUNT(1) >= 100000
    ORDER BY 
        -- Ranks the segments by the median RPM, lowest first
        APPROX_QUANTILES(t.operational_revenue_per_minute, 2)[OFFSET(1)] ASC
    LIMIT 10
)

-- Step 2: Sum the OPERATIONAL revenue for all trips that match the identified Bottom 10 segments
SELECT
    'Bottom_10_Segments' AS segment_group,
    COUNT(t.calculated_total_amount) AS total_trips_in_group,
    
    -- *** KEY CHANGE HERE: Sum only the operational components (calculated_total_amount - tip_amount) ***
    SUM(
        t.calculated_total_amount - t.tip_amount 
    ) AS exact_total_operational_revenue_usd
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t
JOIN
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS tpu
    ON t.PULocationID = tpu.LocationID
JOIN
    Bottom10Segments AS b10
    ON 
        tpu.Zone = b10.pickup_zone
        AND CASE EXTRACT(DAYOFWEEK FROM t.tpep_pickup_datetime)
                WHEN 1 THEN 'Sunday' WHEN 2 THEN 'Monday' WHEN 3 THEN 'Tuesday' WHEN 4 THEN 'Wednesday' 
                WHEN 5 THEN 'Thursday' WHEN 6 THEN 'Friday' WHEN 7 THEN 'Saturday'
            END = b10.day_name
WHERE
    t.trip_duration_minutes > 1.0 
    AND t.calculated_total_amount > 2.0;
