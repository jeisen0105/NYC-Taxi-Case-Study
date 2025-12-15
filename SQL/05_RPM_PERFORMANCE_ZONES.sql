/*
  ANALYSIS FILE: 05_RPM_PERFORMANCE_ZONES.sql (Beginner Focus)
  Purpose: Aggregates performance metrics by Pickup Zone to visualize efficiency on a map.
           This data is used to classify zones as 'Loss' (Red) or 'Profit' (Green) centers,
           based on the OPERATIONAL RPM.
*/
SELECT
    -- Geographic Identifier 
    t1.PULocationID AS LocationID,
    
    -- Core Metric: Calculate the Zone Median OPERATIONAL RPM
    -- NOTE: Using the tip-exclusive metric: operational_revenue_per_minute
    APPROX_QUANTILES(t1.operational_revenue_per_minute, 100)[OFFSET(50)] AS median_operational_rpm_per_zone,
    
    -- Volume Metric: Total number of trips
    COUNT(*) AS number_of_rides,
    
    -- Zone Name: Grabs the human-readable name for the Zone ID.
    ANY_VALUE(t3.Zone) AS ZoneName, 
    
    -- Geometry for Plotting the Map
    ANY_VALUE(ST_ASGEOJSON(t2.zone_geom)) AS zone_geojson

FROM
    `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t1 
INNER JOIN
    -- Join 1: Geometry table (t2) to get the map shape data.
    `nyc-taxi-478617.2024_data.taxi_zone_geom` AS t2 
    ON t1.PULocationID = CAST(t2.zone_id AS INT64)
LEFT JOIN
    -- Join 2: Zone Name Lookup Table (t3) to get the ZoneName.
    `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS t3 
    ON t1.PULocationID = t3.LocationID

GROUP BY
    LocationID 

HAVING
    -- Filter out zones with very low trip counts that skew the Median RPM calculation.
    COUNT(*) > 5

ORDER BY
    median_operational_rpm_per_zone DESC;
