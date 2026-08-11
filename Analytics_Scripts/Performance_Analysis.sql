/*
===============================================================================
Performance Analysis (vs Average, Month-over-Month)
===============================================================================
Purpose:
    - To measure how each unit performs relative to its own average and
      the previous period, useful for spotting degradation or improvement.

SQL Functions Used:
    - LAG(), AVG() OVER(), CASE
===============================================================================
*/

WITH monthly_unit_yield AS (
    SELECT
        DATETRUNC(month, t.full_timestamp) AS reading_month,
        u.unit_name,
        SUM(f.product_yield_tons) AS current_yield
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
    LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
    GROUP BY DATETRUNC(month, t.full_timestamp), u.unit_name
)
SELECT
    reading_month,
    unit_name,
    current_yield,
    AVG(current_yield) OVER (PARTITION BY unit_name) AS avg_yield,
    current_yield - AVG(current_yield) OVER (PARTITION BY unit_name) AS diff_from_avg,
    CASE 
        WHEN current_yield - AVG(current_yield) OVER (PARTITION BY unit_name) > 0 THEN 'Above Avg'
        WHEN current_yield - AVG(current_yield) OVER (PARTITION BY unit_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_comparison,
    -- Month-over-Month comparison
    LAG(current_yield) OVER (PARTITION BY unit_name ORDER BY reading_month) AS prev_month_yield,
    current_yield - LAG(current_yield) OVER (PARTITION BY unit_name ORDER BY reading_month) AS diff_prev_month,
    CASE 
        WHEN current_yield - LAG(current_yield) OVER (PARTITION BY unit_name ORDER BY reading_month) > 0 THEN 'Increase'
        WHEN current_yield - LAG(current_yield) OVER (PARTITION BY unit_name ORDER BY reading_month) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS mom_change
FROM monthly_unit_yield
ORDER BY unit_name, reading_month;

