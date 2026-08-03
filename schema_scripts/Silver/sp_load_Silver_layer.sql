/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE Silver.load_Silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME;
    BEGIN TRY
        PRINT 'Loading Silver Layer';
        PRINT '===================================================';
        SET @start_time = GETDATE();

        IF OBJECT_ID('tempdb..#TempFinalData') IS NOT NULL
            DROP TABLE #TempFinalData;

        PRINT '>>PROCESSING: Deduplication, NULL handling, Standardization';

        WITH RankedData AS (
            SELECT *,
                ROW_NUMBER() OVER (
                    PARTITION BY TRY_CONVERT(DATETIME, Time_stamp, 105), 
                                 UPPER(TRIM(Unit_Name)), 
                                 UPPER(TRIM(Catalyst_Type))
                    ORDER BY Time_stamp
                ) AS row_num
            FROM bronze.petrochemical_operations
        ),
        DedupData AS (
            SELECT * FROM RankedData WHERE row_num = 1
        ),
        AvgByUnit AS (
            SELECT 
                UPPER(TRIM(Unit_Name)) AS Unit_Name,
                AVG(TRY_CAST(Reactor_Temp_C AS FLOAT)) AS avg_reactor_temp,
                AVG(Reactor_Pressure_Bar) AS avg_reactor_pressure_bar,
                AVG(CASE WHEN Catalyst_Age_Days >= 0 THEN Catalyst_Age_Days END) AS avg_catalyst_age,
                AVG(CASE WHEN Sensor_Health_Index BETWEEN 0 AND 1 THEN Sensor_Health_Index END) AS avg_sensor_health
            FROM DedupData
            GROUP BY UPPER(TRIM(Unit_Name))
        )
        SELECT 
            TRY_CONVERT(DATETIME, d.Time_stamp, 105) AS Time_stamp, 
            UPPER(TRIM(d.Unit_Name)) AS Unit_Name,
            UPPER(TRIM(d.Catalyst_Type)) AS Catalyst_Type,
            ISNULL(
                CASE WHEN d.Catalyst_Age_Days >= 0 THEN d.Catalyst_Age_Days END, 
                a.avg_catalyst_age
            ) AS Catalyst_Age_Days,
            ISNULL(d.Reactor_Pressure_Bar, a.avg_reactor_pressure_bar) AS Reactor_Pressure_Bar,
            d.Vibration_Level_mm_s,
            d.Valve_Opening_Percent,
            d.Feedstock_Flow_m3h,
            ISNULL(TRY_CAST(d.Reactor_Temp_C AS FLOAT), a.avg_reactor_temp) AS Reactor_Temp_C,
            ISNULL(
                CASE WHEN d.Sensor_Health_Index BETWEEN 0 AND 1 THEN d.Sensor_Health_Index END, 
                a.avg_sensor_health
            ) AS Sensor_Health_Index,
            d.Electricity_MWh,
            d.Natural_Gas_m3h,
            d.Steam_Tons_h,
            d.Ambient_Temp_C,
            d.Product_Yield_Tons,
            d.Energy_Intensity
        INTO #TempFinalData
        FROM DedupData d
        JOIN AvgByUnit a ON d.Unit_Name = a.Unit_Name;

        PRINT '>>TRUNCATING Silver.petrochemical_operations';
        TRUNCATE TABLE silver.petrochemical_operations;

        PRINT '>>INSERTING Silver.petrochemical_operations';
        INSERT INTO silver.petrochemical_operations (
            Time_stamp, Unit_Name, Catalyst_Type, Catalyst_Age_Days,
            Sensor_Health_Index, Vibration_Level_mm_s, Valve_Opening_Percent,
            Feedstock_Flow_m3h, Reactor_Temp_C, Reactor_Pressure_Bar,
            Electricity_MWh, Natural_Gas_m3h, Steam_Tons_h,
            Ambient_Temp_C, Product_Yield_Tons, Energy_Intensity
        )
        SELECT * FROM #TempFinalData;

        DROP TABLE #TempFinalData;

        SET @end_time = GETDATE();
        PRINT('>>LOAD DURATION:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' Seconds');
        PRINT '>>LOADING IS COMPLETED';

    END TRY
    BEGIN CATCH
        PRINT('========================================================');
        PRINT('ERROR OCCURED WHILE LOADING SILVER LAYER');
        PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
        PRINT('========================================================');
    END CATCH
END
