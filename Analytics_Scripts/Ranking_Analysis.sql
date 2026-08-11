/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank units/catalysts based on performance metrics.
    - To identify top or worst performers.

SQL Functions Used:
    - RANK(), ROW_NUMBER(), TOP, GROUP BY, ORDER BY
===============================================================================
*/

-- Top performing unit by total product yield
SELECT TOP 3
    u.unit_name,
    SUM(f.product_yield_tons) AS total_yield
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
GROUP BY u.unit_name
ORDER BY total_yield DESC;

-- Ranking using window function (flexible, ties handled)
SELECT *
FROM (
    SELECT
        u.unit_name,
        SUM(f.product_yield_tons) AS total_yield,
        RANK() OVER (ORDER BY SUM(f.product_yield_tons) DESC) AS unit_rank
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
    GROUP BY u.unit_name
) ranked_units
WHERE unit_rank <= 3;

-- Least efficient unit (highest energy intensity = least efficient)
SELECT TOP 1
    u.unit_name,
    AVG(f.energy_intensity) AS avg_energy_intensity
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
GROUP BY u.unit_name
ORDER BY avg_energy_intensity DESC;

-- Catalyst type with the best average product yield
SELECT TOP 1
    c.catalyst_type,
    AVG(f.product_yield_tons) AS avg_yield
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_catalyst c ON c.catalyst_key = f.catalyst_key
GROUP BY c.catalyst_type
ORDER BY avg_yield DESC;
