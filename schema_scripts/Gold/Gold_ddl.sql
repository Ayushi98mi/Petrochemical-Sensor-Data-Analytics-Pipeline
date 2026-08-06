/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)
    Since this project has a single consolidated Silver source, dimensions 
    are derived from silver.petrochemical_operations using DISTINCT, and the 
    fact table joins back to these dimensions via their natural keys to 
    obtain surrogate keys.
Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_unit
-- =============================================================================
IF OBJECT_ID('gold.dim_unit', 'V') IS NOT NULL
    DROP VIEW gold.dim_unit;
GO
CREATE VIEW gold.dim_unit AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Unit_Name) AS unit_key,   -- Surrogate key
    Unit_Name                              AS unit_name
FROM (
    SELECT DISTINCT Unit_Name
    FROM silver.petrochemical_operations
) u;
GO

-- =============================================================================
-- Create Dimension: gold.dim_catalyst
-- =============================================================================
IF OBJECT_ID('gold.dim_catalyst', 'V') IS NOT NULL
    DROP VIEW gold.dim_catalyst;
GO
CREATE VIEW gold.dim_catalyst AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Catalyst_Type) AS catalyst_key,   -- Surrogate key
    Catalyst_Type                              AS catalyst_type
FROM (
    SELECT DISTINCT Catalyst_Type
    FROM silver.petrochemical_operations
) c;
GO

-- =============================================================================
-- Create Dimension: gold.dim_time
-- =============================================================================
IF OBJECT_ID('gold.dim_time', 'V') IS NOT NULL
    DROP VIEW gold.dim_time;
GO
CREATE VIEW gold.dim_time AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Time_stamp) AS time_key,   -- Surrogate key
    Time_stamp                              AS full_timestamp,
    CAST(Time_stamp AS DATE)                AS date_only,
    YEAR(Time_stamp)                        AS year,
    MONTH(Time_stamp)                       AS month,
    DATENAME(MONTH, Time_stamp)             AS month_name,
    DAY(Time_stamp)                         AS day,
    DATEPART(HOUR, Time_stamp)              AS hour,
    CASE 
        WHEN DATEPART(HOUR, Time_stamp) BETWEEN 6 AND 13 THEN 'Morning'
        WHEN DATEPART(HOUR, Time_stamp) BETWEEN 14 AND 21 THEN 'Evening'
        ELSE 'Night'
    END                                      AS shift
FROM (
    SELECT DISTINCT Time_stamp
    FROM silver.petrochemical_operations
) t;
GO

-- =============================================================================
-- Create Fact Table: gold.fact_plant_operations
-- =============================================================================
IF OBJECT_ID('gold.fact_plant_operations', 'V') IS NOT NULL
    DROP VIEW gold.fact_plant_operations;
GO
CREATE VIEW gold.fact_plant_operations AS
SELECT
    t.time_key                    AS time_key,
    u.unit_key                    AS unit_key,
    c.catalyst_key                AS catalyst_key,
    s.Catalyst_Age_Days           AS catalyst_age_days,
    s.Sensor_Health_Index         AS sensor_health_index,
    s.Vibration_Level_mm_s        AS vibration_level_mm_s,
    s.Valve_Opening_Percent       AS valve_opening_percent,
    s.Feedstock_Flow_m3h          AS feedstock_flow_m3h,
    s.Reactor_Temp_C              AS reactor_temp_c,
    s.Reactor_Pressure_Bar        AS reactor_pressure_bar,
    s.Electricity_MWh             AS electricity_mwh,
    s.Natural_Gas_m3h             AS natural_gas_m3h,
    s.Steam_Tons_h                AS steam_tons_h,
    s.Ambient_Temp_C              AS ambient_temp_c,
    s.Product_Yield_Tons          AS product_yield_tons,
    s.Energy_Intensity            AS energy_intensity
FROM silver.petrochemical_operations s
LEFT JOIN gold.dim_time t
    ON s.Time_stamp = t.full_timestamp
LEFT JOIN gold.dim_unit u
    ON s.Unit_Name = u.unit_name
LEFT JOIN gold.dim_catalyst c
    ON s.Catalyst_Type = c.catalyst_type;
GO
