-- Identify the payment method and create column
SELECT
    CASE payment_type
        WHEN 1 THEN 'Credit Card'
        WHEN 2 THEN 'Cash'
        ELSE 'Other/Unknown'
    END AS payment_method,
    
    -- Count the total number of trips and create column
    COUNT(*) AS total_trips,
    
    -- Calculate the average tip as a percentage of the total metered charge and create column
    AVG(tip_amount / (fare_amount + tolls_amount + extra)) * 100 AS avg_tip_percentage
    
FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_combined`
WHERE
    payment_type IN (1, 2) -- Focus only on Cash and Credit Card
    --Ensure the total charge is greater than zero to avoid division by zero errors
    AND (fare_amount + tolls_amount + extra) > 5 
    
GROUP BY
    1
ORDER BY
    avg_tip_percentage DESC;
