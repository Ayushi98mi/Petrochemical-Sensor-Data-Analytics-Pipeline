# Petrochemical-Sensor-Data-Analytics-Pipeline
End-to-end data engineering &amp; analytics project on petrochemical sensor data using Medallion Architecture (Bronze-Silver-Gold). Includes SQL-based analytics for business problem-solving, Python for data analysis, and Power BI dashboards for reporting.


## Data Source
**Dataset:** Petrochemical Process Optimization & Maintenance  
**File:** petrochemical_advanced_data.csv  
**Source Platform:** Kaggle 
# Data Architecture 

<img width="1228" height="793" alt="image" src="https://github.com/user-attachments/assets/80377101-6260-410c-a292-e6abcf72df7b" />

## Data Quality Checks (Bronze Layer)

Before moving data to the Silver layer, the following quality checks were 
performed on the raw Bronze data:

### 1. Duplicate Check
Checked for exact duplicate records based on the combination of 
`Timestamp`, `Unit_Name`, and `Catalyst_Type` (these three columns 
together define a unique operational event).

**Result:** 2 duplicate combinations found:
- `01-01-2020 20:00` | Ethylene_Plant_01 | Cobalt_Premium_Z2
- `13-02-2020 12:00` | Ammonia_Unit_02 | Cobalt_Premium_Z2

### 2. NULL Value Check
Checked all 16 columns for missing (NULL) values.

**Result:** 10 rows found with NULL values, distributed across:
- `Sensor_Health_Index`
- `Reactor_Temp_C`
- `Catalyst_Age_Days`

### Resolution
These issues were addressed in the Silver layer:
- Duplicate rows were removed using `ROW_NUMBER()` window function
- NULL values were handled via [imputation/removal]

