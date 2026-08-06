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


- ## Tech Stack

- SQL Server
- SQL
- Python (Pandas, Matplotlib)
- Power BI
- Git & GitHub
- Draw.io (Architecture & Star Schema)

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
- NULL values were handled using appropriate SQL transformations and default business rules during Silver layer processing.

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

