/*
===============================================================================
Catalyst Performance Report
===============================================================================
Purpose:
    - This report consolidates key metrics per catalyst type.

Highlights:
    1. Gathers essential fields such as catalyst type and reading counts.
    2. Aggregates catalyst-level metrics: avg yield, avg age, avg reactor temp.
    3. Calculates a performance segment (High/Mid/Low Performer).
===============================================================================
*/
IF OBJECT_ID('gold.report_catalysts', 'V') IS NOT NULL
    DROP VIEW gold.report_catalysts;
GO

CREATE VIEW gold.report_catalysts AS

WITH base_query AS (
    SELECT
        f.catalyst_key,
        c.catalyst_type,
        f.catalyst_age_days,
        f.product_yield_tons,
        f.reactor_temp_c,
        f.energy_intensity
    FROM gold.fact_plant_operations f
    LEFT JOIN gold.dim_catalyst c ON c.catalyst_key = f.catalyst_key
),

catalyst_aggregation AS (
    SELECT
        catalyst_key,
        catalyst_type,
        COUNT(*) AS total_readings,
        AVG(catalyst_age_days) AS avg_age_days,
        AVG(product_yield_tons) AS avg_yield,
        AVG(reactor_temp_c) AS avg_reactor_temp,
        AVG(energy_intensity) AS avg_energy_intensity
    FROM base_query
    GROUP BY catalyst_key, catalyst_type
)

SELECT
    catalyst_key,
    catalyst_type,
    total_readings,
    avg_age_days,
    avg_yield,
    avg_reactor_temp,
    avg_energy_intensity,
    CASE
        WHEN avg_yield > 85 THEN 'High-Performer'
        WHEN avg_yield >= 70 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS catalyst_segment
FROM catalyst_aggregation;
GO
