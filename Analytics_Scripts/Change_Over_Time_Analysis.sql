/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends and changes in key metrics over time.
    - For time-series analysis and identifying seasonality/shifts.

SQL Functions Used:
    - Date Functions: DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), AVG(), COUNT()
===============================================================================
*/

-- Monthly product yield and average reactor temp
SELECT
    t.year AS reading_year,
    t.month AS reading_month,
    SUM(f.product_yield_tons) AS total_yield,
    AVG(f.reactor_temp_c) AS avg_reactor_temp
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
GROUP BY t.year, t.month
ORDER BY t.year, t.month;

-- Using DATETRUNC for monthly trend
SELECT
    DATETRUNC(month, t.full_timestamp) AS reading_month,
    SUM(f.product_yield_tons) AS total_yield,
    AVG(f.energy_intensity) AS avg_energy_intensity
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
GROUP BY DATETRUNC(month, t.full_timestamp)
ORDER BY DATETRUNC(month, t.full_timestamp);

-- Using FORMAT for readable month labels
SELECT
    FORMAT(t.full_timestamp, 'yyyy-MMM') AS reading_month,
    SUM(f.product_yield_tons) AS total_yield
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
GROUP BY FORMAT(t.full_timestamp, 'yyyy-MMM')
ORDER BY FORMAT(t.full_timestamp, 'yyyy-MMM');

