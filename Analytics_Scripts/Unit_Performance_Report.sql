/*
===============================================================================
Unit Performance Report
===============================================================================
Purpose:
    - This report consolidates key operational metrics per unit.

Highlights:
    1. Gathers essential fields such as unit name and reading counts.
    2. Aggregates unit-level metrics: total yield, avg reactor temp,
       avg sensor health, total energy consumption.
    3. Calculates a performance segment (High/Mid/Low Yield).
===============================================================================
*/
IF OBJECT_ID('gold.report_units', 'V') IS NOT NULL
    DROP VIEW gold.report_units;
GO

CREATE VIEW gold.report_units AS

WITH base_query AS (
    SELECT
        f.unit_key,
        u.unit_name,
        f.product_yield_tons,
        f.reactor_temp_c,
        f.sensor_health_index,
        f.electricity_mwh,
        f.energy_intensity
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_unit u ON u.unit_key = f.unit_key
),

unit_aggregation AS (
    SELECT
        unit_key,
        unit_name,
        COUNT(*) AS total_readings,
        SUM(product_yield_tons) AS total_yield,
        AVG(reactor_temp_c) AS avg_reactor_temp,
        AVG(sensor_health_index) AS avg_sensor_health,
        SUM(electricity_mwh) AS total_electricity,
        AVG(energy_intensity) AS avg_energy_intensity
    FROM base_query
    GROUP BY unit_key, unit_name
)

SELECT
    unit_key,
    unit_name,
    total_readings,
    total_yield,
    avg_reactor_temp,
    avg_sensor_health,
    total_electricity,
    avg_energy_intensity,
    CASE
        WHEN total_yield > 300000 THEN 'High-Yield'
        WHEN total_yield >= 100000 THEN 'Mid-Yield'
        ELSE 'Low-Yield'
    END AS yield_segment,
    CASE
        WHEN avg_sensor_health >= 0.8 THEN 'Healthy'
        WHEN avg_sensor_health >= 0.6 THEN 'Moderate'
        ELSE 'At Risk'
    END AS health_status
FROM unit_aggregation;
GO
