/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For catalyst-age segmentation or equipment-health segmentation.

SQL Functions Used:
    - CASE, GROUP BY
===============================================================================
*/

-- Segment readings by catalyst age and count how many fall in each segment
WITH catalyst_age_segments AS (
    SELECT
        catalyst_age_days,
        CASE 
            WHEN catalyst_age_days < 90 THEN 'New (<90 days)'
            WHEN catalyst_age_days BETWEEN 90 AND 180 THEN 'Mid-life (90-180 days)'
            WHEN catalyst_age_days BETWEEN 181 AND 270 THEN 'Aging (181-270 days)'
            ELSE 'End-of-life (270+ days)'
        END AS age_segment
    FROM gold.fact_plant_operations
)
SELECT 
    age_segment,
    COUNT(*) AS total_readings
FROM catalyst_age_segments
GROUP BY age_segment
ORDER BY total_readings DESC;

-- Segment readings by equipment health (Sensor_Health_Index)
WITH health_segments AS (
    SELECT
        sensor_health_index,
        CASE 
            WHEN sensor_health_index >= 0.8 THEN 'Healthy'
            WHEN sensor_health_index >= 0.6 THEN 'Moderate'
            ELSE 'At Risk'
        END AS health_segment
    FROM gold.fact_plant_operations
)
SELECT
    health_segment,
    COUNT(*) AS total_readings
FROM health_segments
GROUP BY health_segment
ORDER BY total_readings DESC;

