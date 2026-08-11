/*
===============================================================================
Part-to-Whole Analysis
===============================================================================
Purpose:
    - To evaluate each unit's/catalyst's contribution to overall metrics.
    - Useful for identifying which unit drives most energy consumption.

SQL Functions Used:
    - SUM(), Window Functions: SUM() OVER()
===============================================================================
*/

-- Which unit contributes the most to overall electricity consumption?
WITH unit_electricity AS (
    SELECT
        u.unit_name,
        SUM(f.electricity_mwh) AS total_electricity
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
    GROUP BY u.unit_name
)
SELECT
    unit_name,
    total_electricity,
    SUM(total_electricity) OVER () AS overall_electricity,
    ROUND((CAST(total_electricity AS FLOAT) / SUM(total_electricity) OVER ()) * 100, 2) AS pct_of_total
FROM unit_electricity
ORDER BY total_electricity DESC;


