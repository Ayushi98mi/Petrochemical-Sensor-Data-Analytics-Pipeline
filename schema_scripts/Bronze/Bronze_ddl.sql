/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'Bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'Bronze' Tables
===============================================================================
*/

IF OBJECT_ID('Bronze.petrochemical_operations' ,'U') IS NOT NULL
DROP TABLE Bronze.petrochemical_operations;
CREATE TABLE Bronze.petrochemical_operations (
    Time_stamp               NVARCHAR(50),
    Unit_Name               NVARCHAR(50),
    Catalyst_Type            NVARCHAR(50),
    Catalyst_Age_Days         INT,
    Sensor_Health_Index        FLOAT,
    Vibration_Level_mm_s       FLOAT,
    Valve_Opening_Percent       FLOAT,
    Feedstock_Flow_m3h         FLOAT,
    Reactor_Temp_C            NVARCHAR(50),
    Reactor_Pressure_Bar        FLOAT,
    Electricity_MWh           FLOAT,
    Natural_Gas_m3h           FLOAT,
    Steam_Tons_h             FLOAT,
    Ambient_Temp_C            FLOAT,
    Product_Yield_Tons         FLOAT,
    Energy_Intensity          FLOAT
);
