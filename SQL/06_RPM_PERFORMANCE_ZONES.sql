/*
  ANALYSIS FILE: 06_RPM_PERFORMANCE_ZONES.sql 
  Purpose: Groups performance by neighborhood (Zone). 
           We connect our trip data to map shapes (GeoJSON) to see 
           which parts of NYC are "Efficiency Cold Spots."
*/

SELECT
  -- The ID: Which neighborhood are we looking at?
  t1.PULocationID AS LocationID,
  
  -- The Efficiency: What is the Median RPM for this specific area?
  APPROX_QUANTILES(t1.operational_revenue_per_minute, 100)[OFFSET(50)] AS median_rpm_per_zone,
  
  -- The Volume: How busy is this neighborhood?
  COUNT(*) AS number_of_rides,
  
  -- The Name: Get the human-readable name 
  ANY_VALUE(t3.Zone) AS zone_name, 
  
  -- The Shape: Get the map coordinates so we can draw the zone.
  ANY_VALUE(ST_ASGEOJSON(t2.zone_geom)) AS zone_map_shape

FROM
  `nyc-taxi-478617.2024_data.yellow_trips_2024_cleaned` AS t1 

-- JOIN 1: We bring in the "Shape Table" so we know how to draw the map.
INNER JOIN
  `nyc-taxi-478617.2024_data.taxi_zone_geom` AS t2 
  ON t1.PULocationID = CAST(t2.zone_id AS INT64)

-- JOIN 2: We bring in the "Name Table" so we know what the neighborhood is called.
LEFT JOIN
  `nyc-taxi-478617.2024_data.taxi_zone_lookup` AS t3 
  ON t1.PULocationID = t3.LocationID

GROUP BY
  -- Group everything by the Neighborhood ID
  LocationID 

HAVING
  -- Only show zones that had more than 5 rides 
  COUNT(*) > 5

ORDER BY
  -- Show the most profitable zones at the top
  median_rpm_per_zone DESC;
