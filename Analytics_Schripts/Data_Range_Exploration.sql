/*
===============================================================================
Date Range Exploration
===============================================================================
Purpose:
    - To determine the temporal boundaries of the sensor data.
    - To understand the range of historical data collected.

SQL Functions Used:
    - MIN(), MAX(), DATEDIFF()
===============================================================================
*/

-- Determine the first and last recorded timestamp and total duration in months
SELECT 
    MIN(full_timestamp) AS first_reading,
    MAX(full_timestamp) AS last_reading,
    DATEDIFF(MONTH, MIN(full_timestamp), MAX(full_timestamp)) AS data_range_months
FROM gold.dim_time;
