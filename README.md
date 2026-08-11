# Petrochemical-Sensor-Data-Analytics-Pipeline
End-to-end data engineering &amp; analytics project on petrochemical sensor data using Medallion Architecture (Bronze-Silver-Gold). Includes SQL-based analytics for business problem-solving, Python for data analysis, and Power BI dashboards for reporting.


## Data Source

- **Dataset:** Petrochemical Process Optimization & Maintenance
- **Source:** Kaggle
- **Records:** 10,000+
- **Format:** CSV
- **Domain:** Petrochemical Plant Operations


  
- 
# Data Architecture 

<img width="1191" height="771" alt="DATA_ARCHITECTURE drawio" src="https://github.com/user-attachments/assets/495da2bb-2fcf-446f-a33a-699aede2e416" />


## Tech Stack
- SQL Server
- SQL
- Power BI - planned for exploratory analysis, upcoming*
- Git & GitHub
- Draw.io (Architecture & Star Schema)

*Python (Pandas, Matplotlib) — planned for exploratory analysis, upcoming*

 ## Medallion Architecture

### Bronze Layer
- Raw data ingestion
- No transformations
- Source data preserved

### Silver Layer
- Removed duplicates
- Handled missing values
- Standardized text values
- Converted data types
- Data validation

### Gold Layer
- Star Schema
- Dimension tables
- Fact table
- Business-ready analytical model

## SQL Transformations

- Duplicate Removal using `ROW_NUMBER()`
- NULL Handling
- Data Standardization (`UPPER()`, `TRIM()`)
- Data Type Conversion (`TRY_CONVERT()`)
- Dimension Table Creation
- Fact Table Creation
- Surrogate Key Generation using `ROW_NUMBER()`

# Data Flow Diagram

<img width="891" height="384" alt="FLOW_DIAGRAM drawio" src="https://github.com/user-attachments/assets/91c291cb-b876-4dce-a8f6-f107ca9eeca7" />


## Data Quality Checks (Bronze Layer)

Before moving data to the Silver layer, the following quality checks were 
performed on the raw Bronze data:

### 1. Duplicate Check
Checked for exact duplicate records based on the combination of 
`Timestamp`, `Unit_Name`, and `Catalyst_Type` (these three columns 
together define a unique operational event).

**Result:** 2 duplicate combinations found on initial raw-text comparison 
(a 3rd hidden duplicate was later discovered once Timestamp and Unit_Name 
were standardized during cleaning):
- `01-01-2020 20:00` | Ethylene_Plant_01 | Cobalt_Premium_Z2
- `13-02-2020 12:00` | Ammonia_Unit_02 | Cobalt_Premium_Z2

### 2. NULL Value Check
Checked all 16 columns for missing (NULL) values.

**Result:** 10 rows found with NULL values, distributed across:
- `Sensor_Health_Index`
- `Reactor_Temp_C`
- `Catalyst_Age_Days`

### 3. Range & Negative Value Validation
Checked business-logical bounds on key sensor readings:
- `Sensor_Health_Index` should be between 0 and 1
- `Valve_Opening_Percent` should be between 0 and 100
- No numeric column should contain negative values, except `Ambient_Temp_C` 
  (which can legitimately be negative in winter conditions)

**Result:**
- `Sensor_Health_Index`: 6 rows out of range (0–1), including 2 negative values
- `Valve_Opening_Percent`: 0 rows out of range — no issue found
- Negative values across all other columns: 5 total (3 in `Catalyst_Age_Days`, 
  2 in `Sensor_Health_Index`)

### 4. Text Standardization Check (Case & Spacing)
Checked `Unit_Name` and `Catalyst_Type` for leading/trailing spaces and 
case inconsistencies (e.g. `Ethylene_Plant_01` vs `ETHYLENE_plant_01`), 
using `TRIM()` for spacing and a `VARBINARY` cast for case-sensitive 
comparison, since SQL Server is case-insensitive by default.

**Result:**
- Spacing: 0 issues found
- Case inconsistencies: 8 raw variants found across 3 real Unit_Name values, 
  and similar variants in `Catalyst_Type`

### Resolution
These issues were addressed in the Silver layer:
- **Duplicates** were removed using a `ROW_NUMBER()` window function, 
  partitioned on the *standardized* (case-normalized, converted) versions 
  of Timestamp, Unit_Name, and Catalyst_Type — not the raw values — to 
  ensure hidden duplicates were also caught.
- **NULL and out-of-range values** were imputed using Unit-wise averages, 
  calculated only from valid, in-range readings (invalid values were 
  excluded from the average calculation itself).
- **Text fields** were standardized using `UPPER(TRIM())` to merge all 
  case/spacing variants into a single consistent value per category.

- ## Gold Layer

The Gold layer follows a Star Schema consisting of:

- dim_time
- dim_unit
- dim_catalyst
- fact_plant_operations

  # Star Schema
  <img width="947" height="1052" alt="Star_Schema drawio" src="https://github.com/user-attachments/assets/95de89c7-4999-4629-9dca-8e7aee53b55c" />


## Data Catalog

Detailed description of all Gold Layer tables and columns is available here:

docs/data_catalog.md

