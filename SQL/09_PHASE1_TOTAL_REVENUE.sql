/*
  ANALYSIS FILE: 09_PHASE1_TOTAL_REVENUE.sql
  Purpose: Calculates the two income streams for the Pilot:
           A. Surcharge Revenue (from the Top 10 Cash Cows)
           B. Recovered Revenue (from the Bottom 10 AI Fixes)
           C. The Grand Total (A + B)
*/

WITH Surcharge_Calculation AS (
    -- PART A: Funding from the Top 10 segments
    SELECT
        -- Math: (Total Trips * $0.99 Fee) * 85% (assuming some riders switch to subway)
        SUM(total_trips * 0.99 * 0.85) AS total_surcharge_funding
    FROM
        `nyc-taxi-478617.2024_data.top_10`
),

Recovery_Calculation AS (
    -- PART B: Savings from the Bottom 10 segments
    SELECT
        -- Math: (Current Total Revenue) * 5% Efficiency Gain
        -- We estimate the AI can recover 5% of "lost time" in these slow zones.
        SUM(avg_duration * total_trips * median_rpm * 0.05) AS total_recovered_efficiency
    FROM
        `nyc-taxi-478617.2024_data.bottom_10`
)

-- FINAL STEP: Combine the two buckets into one result
SELECT
    -- Show the Funding total
    ROUND(S.total_surcharge_funding, 2) AS funding_revenue_usd,
    
    -- Show the Recovery total
    ROUND(R.total_recovered_efficiency, 2) AS recovery_revenue_usd,
    
    -- Show the Grand Total
    ROUND(S.total_surcharge_funding + R.total_recovered_efficiency, 2) AS total_pilot_revenue_usd

FROM
    Surcharge_Calculation AS S, 
    Recovery_Calculation AS R;
