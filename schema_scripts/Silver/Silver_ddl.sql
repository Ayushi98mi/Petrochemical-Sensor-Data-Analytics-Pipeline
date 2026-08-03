/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

IF OBJECT_ID('silver.petrochemical_operations', 'U') IS NOT NULL
    DROP TABLE silver.petrochemical_operations;
GO

CREATE TABLE silver.petrochemical_operations (
    operation_id           INT IDENTITY(1,1) PRIMARY KEY,   -- Surrogate Key
    Time_stamp               DATETIME,
    Unit_Name               NVARCHAR(50),
    Catalyst_Type            NVARCHAR(50),
    Catalyst_Age_Days         INT,
    Sensor_Health_Index        FLOAT,
    Vibration_Level_mm_s       FLOAT,
    Valve_Opening_Percent       FLOAT,
    Feedstock_Flow_m3h         FLOAT,
    Reactor_Temp_C            FLOAT,
    Reactor_Pressure_Bar        FLOAT,
    Electricity_MWh           FLOAT,
    Natural_Gas_m3h           FLOAT,
    Steam_Tons_h             FLOAT,
    Ambient_Temp_C            FLOAT,
    Product_Yield_Tons         FLOAT,
    Energy_Intensity          FLOAT,
    dwh_create_date           DATETIME2 DEFAULT GETDATE()    -- Metadata column
);
GO



