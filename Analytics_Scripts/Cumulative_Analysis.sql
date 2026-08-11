/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Running total of product yield and moving average of energy intensity
SELECT
    reading_month,
    total_yield,
    SUM(total_yield) OVER (ORDER BY reading_month) AS running_total_yield,
    AVG(avg_energy_intensity) OVER (ORDER BY reading_month) AS moving_avg_energy_intensity
FROM (
    SELECT 
        DATETRUNC(month, t.full_timestamp) AS reading_month,
        SUM(f.product_yield_tons) AS total_yield,
        AVG(f.energy_intensity) AS avg_energy_intensity
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
    GROUP BY DATETRUNC(month, t.full_timestamp)
) monthly_summary
ORDER BY reading_month;
