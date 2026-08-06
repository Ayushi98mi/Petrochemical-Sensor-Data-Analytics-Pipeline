/*
=====================================================================
DATA QUALITY REPORT — Petrochemical Sensor Data Pipeline
Bronze Layer (Before Cleaning) vs Silver Layer (After Cleaning)
=====================================================================
This script documents every data quality check performed during the
Bronze -> Silver transformation, along with the actual results found
during development, and a matching verification query to re-confirm
the fix on the cleaned data.
*/

USE PetrochemicalAnalytics;
GO


/* =====================================================================
   CHECK 1: Total Row Count
   ===================================================================== */

-- BEFORE (Bronze - raw data)
SELECT COUNT(*) AS total_rows FROM bronze.petrochemical_operations;
-- RESULT FOUND: 10,002 rows

-- AFTER (Silver - cleaned data)
SELECT COUNT(*) AS total_rows FROM silver.petrochemical_operations;
-- RESULT FOUND: 9,999 rows (3 duplicate groups removed)


/* =====================================================================
   CHECK 2: Exact Duplicate Rows
   (based on Time_stamp + Unit_Name + Catalyst_Type, since these three
   columns together define a unique operational event)
   ===================================================================== */

-- BEFORE (Bronze - raw, case-sensitive comparison)
SELECT Time_stamp, Unit_Name, Catalyst_Type, COUNT(*) AS Counts
FROM bronze.petrochemical_operations
GROUP BY Time_stamp, Unit_Name, Catalyst_Type
HAVING COUNT(*) > 1;
-- RESULT FOUND: 2 duplicate combinations detected on raw text comparison
--   (a 3rd hidden duplicate was later found once Time_stamp/Unit_Name
--   were standardized — see note in Main Query section)

-- AFTER (Silver - standardized comparison)
SELECT Time_stamp, Unit_Name, Catalyst_Type, COUNT(*)
FROM silver.petrochemical_operations
GROUP BY Time_stamp, Unit_Name, Catalyst_Type
HAVING COUNT(*) > 1;
-- RESULT FOUND: 0 rows (all duplicates successfully removed)


/* =====================================================================
   CHECK 3: NULL Values (across all columns)
   ===================================================================== */

-- BEFORE (Bronze)
SELECT *
FROM bronze.petrochemical_operations
WHERE Time_stamp IS NULL 
   OR Unit_Name IS NULL 
   OR Catalyst_Type IS NULL
   OR Catalyst_Age_Days IS NULL
   OR Sensor_Health_Index IS NULL
   OR Vibration_Level_mm_s IS NULL
   OR Valve_Opening_Percent IS NULL
   OR Feedstock_Flow_m3h IS NULL
   OR Reactor_Temp_C IS NULL
   OR Reactor_Pressure_Bar IS NULL
   OR Electricity_MWh IS NULL
   OR Natural_Gas_m3h IS NULL
   OR Steam_Tons_h IS NULL
   OR Ambient_Temp_C IS NULL
   OR Product_Yield_Tons IS NULL
   OR Energy_Intensity IS NULL;
-- RESULT FOUND: 10 rows with NULLs, spread across
--   Sensor_Health_Index, Reactor_Temp_C, and Catalyst_Age_Days

-- AFTER (Silver)
SELECT COUNT(*) AS rows_with_nulls
FROM silver.petrochemical_operations
WHERE Catalyst_Age_Days IS NULL
   OR Sensor_Health_Index IS NULL
   OR Reactor_Temp_C IS NULL;
-- RESULT FOUND: 0 (all NULLs imputed with Unit-wise average)


/* =====================================================================
   CHECK 4: Unwanted Leading/Trailing Spaces (Unit_Name, Catalyst_Type)
   ===================================================================== */

-- BEFORE (Bronze)
SELECT Unit_Name
FROM bronze.petrochemical_operations
WHERE Unit_Name != TRIM(Unit_Name);

SELECT Catalyst_Type
FROM bronze.petrochemical_operations
WHERE Catalyst_Type != TRIM(Catalyst_Type);
-- RESULT FOUND: 0 rows in both — no space issues existed

-- AFTER: not applicable (already clean before cleaning too)


/* =====================================================================
   CHECK 5: Case Inconsistencies (Unit_Name, Catalyst_Type)
   SQL Server is case-insensitive by default, so VARBINARY cast is used
   to force a case-sensitive comparison.
   ===================================================================== */

-- BEFORE (Bronze)
SELECT Unit_Name, COUNT(*) 
FROM bronze.petrochemical_operations
GROUP BY Unit_Name, CAST(Unit_Name AS VARBINARY(100))
ORDER BY Unit_Name;
-- RESULT FOUND: 8 distinct case-variants across 3 real units
--   e.g. "Ammonia_Unit_02" vs "Ammonia_UNit_02" (count = 1, typo)

SELECT Catalyst_Type, COUNT(*)
FROM bronze.petrochemical_operations
GROUP BY Catalyst_Type, CAST(Catalyst_Type AS VARBINARY(100))
ORDER BY Catalyst_Type;
-- RESULT FOUND: similar case-variants for Catalyst_Type

-- AFTER (Silver - post UPPER(TRIM()) standardization)
SELECT Unit_Name, COUNT(*)
FROM silver.petrochemical_operations
GROUP BY Unit_Name, CAST(Unit_Name AS VARBINARY(100))
ORDER BY Unit_Name;
-- RESULT FOUND: exactly 3 rows (AMMONIA_UNIT_02, ETHYLENE_PLANT_01,
--   METHANOL_COMPLEX_03) — all variants merged correctly

SELECT Catalyst_Type, COUNT(*)
FROM silver.petrochemical_operations
GROUP BY Catalyst_Type, CAST(Catalyst_Type AS VARBINARY(100))
ORDER BY Catalyst_Type;
-- RESULT FOUND: exactly 3 rows, standardized


/* =====================================================================
   CHECK 6: Hidden Empty/Space-Only Values (not caught by IS NULL)
   ===================================================================== */

-- BEFORE (Bronze)
SELECT *
FROM bronze.petrochemical_operations
WHERE LTRIM(RTRIM(CAST(Reactor_Temp_C AS NVARCHAR(50)))) = ''
   OR LTRIM(RTRIM(CAST(Sensor_Health_Index AS NVARCHAR(50)))) = ''
   OR LTRIM(RTRIM(CAST(Catalyst_Age_Days AS NVARCHAR(50)))) = '';

SELECT *
FROM bronze.petrochemical_operations
WHERE TRIM(Unit_Name) = ''
   OR TRIM(Catalyst_Type) = '';
-- RESULT FOUND: 0 rows in both — no hidden empty/space-only values


/* =====================================================================
   CHECK 7: Timestamp Format Consistency
   ===================================================================== */

-- BEFORE (Bronze)
SELECT DISTINCT Time_stamp
FROM bronze.petrochemical_operations
WHERE TRY_CONVERT(DATETIME, Time_stamp, 105) IS NULL;
-- RESULT FOUND: 0 rows — all timestamps consistently in dd-mm-yyyy format


/* =====================================================================
   CHECK 8: Sensor_Health_Index Range Validation (must be 0 to 1)
   ===================================================================== */

-- BEFORE (Bronze)
SELECT COUNT(*) AS sensor_out_of_range
FROM bronze.petrochemical_operations
WHERE Sensor_Health_Index < 0 OR Sensor_Health_Index > 1;
-- RESULT FOUND: 6 rows out of range (includes 2 negative values)

-- AFTER (Silver)
SELECT COUNT(*) AS sensor_out_of_range
FROM silver.petrochemical_operations
WHERE Sensor_Health_Index NOT BETWEEN 0 AND 1;
-- RESULT FOUND: 0 (out-of-range values replaced with Unit-wise average)


/* =====================================================================
   CHECK 9: Valve_Opening_Percent Range Validation (must be 0 to 100)
   ===================================================================== */

-- BEFORE (Bronze)
SELECT COUNT(*) AS valve_out_of_range
FROM bronze.petrochemical_operations
WHERE Valve_Opening_Percent < 0 OR Valve_Opening_Percent > 100;
-- RESULT FOUND: 0 — no issue, no fix required


/* =====================================================================
   CHECK 10: Negative Values (all numeric columns except Ambient_Temp_C,
   which can legitimately be negative in winter conditions)
   ===================================================================== */

-- BEFORE (Bronze) — combined check
SELECT COUNT(*) AS negative_values
FROM bronze.petrochemical_operations
WHERE Catalyst_Age_Days < 0
   OR Sensor_Health_Index < 0
   OR Vibration_Level_mm_s < 0
   OR Valve_Opening_Percent < 0
   OR Feedstock_Flow_m3h < 0
   OR TRY_CAST(Reactor_Temp_C AS FLOAT) < 0
   OR Reactor_Pressure_Bar < 0
   OR Electricity_MWh < 0
   OR Natural_Gas_m3h < 0
   OR Steam_Tons_h < 0
   OR Product_Yield_Tons < 0
   OR Energy_Intensity < 0;
-- RESULT FOUND: 5 rows total

-- BEFORE (Bronze) — column-by-column breakdown
SELECT 
    SUM(CASE WHEN Catalyst_Age_Days < 0 THEN 1 ELSE 0 END) AS neg_catalyst_age,
    SUM(CASE WHEN Sensor_Health_Index < 0 THEN 1 ELSE 0 END) AS neg_sensor_health,
    SUM(CASE WHEN Vibration_Level_mm_s < 0 THEN 1 ELSE 0 END) AS neg_vibration,
    SUM(CASE WHEN Valve_Opening_Percent < 0 THEN 1 ELSE 0 END) AS neg_valve,
    SUM(CASE WHEN Feedstock_Flow_m3h < 0 THEN 1 ELSE 0 END) AS neg_feedstock,
    SUM(CASE WHEN TRY_CAST(Reactor_Temp_C AS FLOAT) < 0 THEN 1 ELSE 0 END) AS neg_reactor_temp,
    SUM(CASE WHEN Reactor_Pressure_Bar < 0 THEN 1 ELSE 0 END) AS neg_reactor_pressure,
    SUM(CASE WHEN Electricity_MWh < 0 THEN 1 ELSE 0 END) AS neg_electricity,
    SUM(CASE WHEN Natural_Gas_m3h < 0 THEN 1 ELSE 0 END) AS neg_natural_gas,
    SUM(CASE WHEN Steam_Tons_h < 0 THEN 1 ELSE 0 END) AS neg_steam,
    SUM(CASE WHEN Product_Yield_Tons < 0 THEN 1 ELSE 0 END) AS neg_product_yield,
    SUM(CASE WHEN Energy_Intensity < 0 THEN 1 ELSE 0 END) AS neg_energy_intensity
FROM bronze.petrochemical_operations;
-- RESULT FOUND: neg_catalyst_age = 3, neg_sensor_health = 2, all others = 0
--   (3 + 2 = 5, matches the combined check above)

-- AFTER (Silver)
SELECT COUNT(*) AS out_of_range_or_negative
FROM silver.petrochemical_operations
WHERE Sensor_Health_Index NOT BETWEEN 0 AND 1
   OR Catalyst_Age_Days < 0;
-- RESULT FOUND: 0 (negative Catalyst_Age_Days and Sensor_Health_Index
--   values replaced with Unit-wise average)


/* =====================================================================
   SUMMARY
   =====================================================================
   Issue                          | Bronze (Before) | Silver (After)
   --------------------------------|------------------|------------------
   Total rows                      | 10,002           | 9,999
   Exact duplicates                | 3 groups         | 0
   NULL values                     | 10 rows          | 0
   Unwanted spaces                 | 0                | 0 (not an issue)
   Case inconsistencies            | 8 variants       | 3 clean values
   Hidden empty/space-only values  | 0                | 0 (not an issue)
   Timestamp format issues         | 0                | 0 (not an issue)
   Sensor_Health_Index out-of-range| 6 rows           | 0
   Valve_Opening_Percent out-of-range | 0             | 0 (not an issue)
   Negative values (all columns)   | 5 rows           | 0
   ===================================================================== */
