/*
===============================================================================
Measures Exploration (Key Metrics)
===============================================================================
Purpose:
    - To calculate aggregated metrics for quick operational insights.
    - To identify overall trends or spot anomalies.

SQL Functions Used:
    - COUNT(), SUM(), AVG()
===============================================================================
*/

-- Total product yield across all readings
SELECT SUM(product_yield_tons) AS total_product_yield FROM gold.fact_plant_operations;

-- Average reactor temperature
SELECT AVG(reactor_temp_c) AS avg_reactor_temp FROM gold.fact_plant_operations;

-- Average energy intensity (efficiency indicator)
SELECT AVG(energy_intensity) AS avg_energy_intensity FROM gold.fact_plant_operations;

-- Total electricity, natural gas, and steam consumed
SELECT 
    SUM(electricity_mwh) AS total_electricity_mwh,
    SUM(natural_gas_m3h) AS total_natural_gas,
    SUM(steam_tons_h) AS total_steam
FROM gold.fact_plant_operations;

-- Total number of readings recorded
SELECT COUNT(*) AS total_readings FROM gold.fact_plant_operations;

-- Total number of units and catalyst types in operation
SELECT COUNT(*) AS total_units FROM gold.dim_unit;
SELECT COUNT(*) AS total_catalysts FROM gold.dim_catalyst;

-- Generate a report showing all key operational metrics
SELECT 'Total Product Yield (Tons)' AS measure_name, SUM(product_yield_tons) AS measure_value FROM gold.fact_plant_operations
UNION ALL
SELECT 'Avg Reactor Temp (C)', AVG(reactor_temp_c) FROM gold.fact_plant_operations
UNION ALL
SELECT 'Avg Energy Intensity', AVG(energy_intensity) FROM gold.fact_plant_operations
UNION ALL
SELECT 'Total Electricity (MWh)', SUM(electricity_mwh) FROM gold.fact_plant_operations
UNION ALL
SELECT 'Total Readings', COUNT(*) FROM gold.fact_plant_operations
UNION ALL
SELECT 'Total Units', COUNT(*) FROM gold.dim_unit
UNION ALL
SELECT 'Total Catalyst Types', COUNT(*) FROM gold.dim_catalyst;
