
/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To quantify data and group results by specific dimensions.
    - For understanding distribution across units and catalysts.

SQL Functions Used:
    - SUM(), COUNT(), AVG(), GROUP BY, ORDER BY
===============================================================================
*/

-- Total product yield by unit
SELECT
    u.unit_name,
    SUM(f.product_yield_tons) AS total_yield
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
GROUP BY u.unit_name
ORDER BY total_yield DESC;

-- Average reactor temperature by catalyst type
SELECT
    c.catalyst_type,
    AVG(f.reactor_temp_c) AS avg_reactor_temp
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_catalyst c ON c.catalyst_key = f.catalyst_key
GROUP BY c.catalyst_type
ORDER BY avg_reactor_temp DESC;

-- Total energy consumption (electricity) by unit
SELECT
    u.unit_name,
    SUM(f.electricity_mwh) AS total_electricity
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
GROUP BY u.unit_name
ORDER BY total_electricity DESC;

-- Average sensor health index by unit (equipment condition check)
SELECT
    u.unit_name,
    AVG(f.sensor_health_index) AS avg_sensor_health
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
GROUP BY u.unit_name
ORDER BY avg_sensor_health DESC;

-- Readings distribution by shift (Morning/Evening/Night)
SELECT
    t.shift,
    COUNT(*) AS total_readings
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_time t ON t.time_key = f.time_key
GROUP BY t.shift
ORDER BY total_readings DESC;

