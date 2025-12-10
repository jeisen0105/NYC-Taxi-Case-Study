/*
  ANALYSIS FILE: 07_ESTIMATED_ROI.sql
  Purpose: Calculates the final Total Estimated Revenue Impact (ROI) for Phase 1 of the strategy,
           by summing the recovery value (Fix) and the surcharge value (Fund).
*/
SELECT
    -- 1. Total Estimated Recovery Value (Gained by fixing the Bottom 10)
    (
        SELECT
            -- Calculation: SUM [(Target RPM - Segment RPM) * Total Trips * Average Duration]
            SUM(
                (1.89 - median_rpm_usd_per_min) * total_trips_in_segment * average_trip_duration_minutes
            )
        FROM
            `nyc-taxi-478617.2024_data.bottom_10_segments_for_roi`
    ) AS Total_Estimated_Recovery_Value,
    
    -- 2. Total Estimated Surcharge Revenue (Gained by surcharging the Top 10)
    (
        SELECT
            -- Calculation: SUM [(Segment RPM - Target RPM) * Total Trips * Average Duration]
            SUM(
                (median_rpm_usd_per_min - 1.89) * total_trips_in_segment * average_trip_duration_minutes
            )
        FROM
            `nyc-taxi-478617.2024_data.top_10_segments_for_roi`
    ) AS Total_Estimated_Surcharge_Revenue,
    
    -- 3. Final Headline Figure: Total ROI (Sum of Recovery + Surcharge)
    (
        (
            SELECT SUM((1.89 - median_rpm_usd_per_min) * total_trips_in_segment * average_trip_duration_minutes)
            FROM `nyc-taxi-478617.2024_data.bottom_10_segments_for_roi`
        ) 
        + 
        (
            SELECT SUM((median_rpm_usd_per_min - 1.89) * total_trips_in_segment * average_trip_duration_minutes)
            FROM `nyc-taxi-478617.2024_data.top_10_segments_for_roi`
        )
    ) AS Total_Estimated_Revenue_Impact
