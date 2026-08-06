Data Catalog for Gold Layer
Overview

The Gold Layer represents the business-ready data model designed for analytics, reporting, and dashboarding. It follows a Star Schema, consisting of dimension tables and a central fact table that stores petrochemical plant operational metrics.

1. gold.dim_unit

Purpose: Stores information about the processing units operating in the petrochemical plant.

| Column Name | Data Type    | Description                                                                                         |
| ----------- | ------------ | --------------------------------------------------------------------------------------------------- |
| unit_key    | INT          | Surrogate key uniquely identifying each processing unit in the dimension table.                     |
| unit_name   | NVARCHAR(50) | Name of the petrochemical processing unit (e.g., Cracking Unit, Distillation Unit, Reforming Unit). |

2. gold.dim_catalyst

Purpose: Stores information about catalyst types used during plant operations.

| Column Name   | Data Type    | Description                                                                                 |
| ------------- | ------------ | ------------------------------------------------------------------------------------------- |
| catalyst_key  | INT          | Surrogate key uniquely identifying each catalyst type.                                      |
| catalyst_type | NVARCHAR(50) | Name or type of catalyst used in the production process (e.g., Zeolite, Alumina, Platinum). |

3. gold.dim_time

Purpose: Stores time-related attributes to support time-based analysis and reporting.

| Column Name    | Data Type    | Description                                                        |
| -------------- | ------------ | ------------------------------------------------------------------ |
| time_key       | INT          | Surrogate key uniquely identifying each timestamp record.          |
| full_timestamp | DATETIME     | Complete date and time of the plant operation.                     |
| date_only      | DATE         | Date extracted from the timestamp.                                 |
| year           | INT          | Calendar year of the operation.                                    |
| month          | INT          | Month number (1–12).                                               |
| month_name     | NVARCHAR(20) | Name of the month (e.g., January, February).                       |
| day            | INT          | Day of the month.                                                  |
| hour           | INT          | Hour of the day (0–23).                                            |
| shift          | NVARCHAR(20) | Operational shift derived from the hour (Morning, Evening, Night). |

4. gold.fact_plant_operations

Purpose: Stores operational process measurements collected from the petrochemical plant. Each record represents a single operational observation and links to the related dimension tables.

| Column Name           | Data Type | Description                                                                                |
| --------------------- | --------- | ------------------------------------------------------------------------------------------ |
| time_key              | INT       | Foreign key linking to the Time dimension.                                                 |
| unit_key              | INT       | Foreign key linking to the Unit dimension.                                                 |
| catalyst_key          | INT       | Foreign key linking to the Catalyst dimension.                                             |
| catalyst_age_days     | INT       | Number of days the catalyst has been in use.                                               |
| sensor_health_index   | FLOAT     | Health score of the monitoring sensors, indicating sensor reliability.                     |
| vibration_level_mm_s  | FLOAT     | Measured equipment vibration level in millimeters per second (mm/s).                       |
| valve_opening_percent | FLOAT     | Percentage opening of the control valve during operation.                                  |
| feedstock_flow_m3h    | FLOAT     | Feedstock flow rate entering the reactor, measured in cubic meters per hour (m³/h).        |
| reactor_temp_c        | FLOAT     | Reactor operating temperature in degrees Celsius (°C).                                     |
| reactor_pressure_bar  | FLOAT     | Reactor operating pressure measured in bar.                                                |
| electricity_mwh       | FLOAT     | Electricity consumed during the operation, measured in megawatt-hours (MWh).               |
| natural_gas_m3h       | FLOAT     | Natural gas consumption rate measured in cubic meters per hour (m³/h).                     |
| steam_tons_h          | FLOAT     | Steam consumption measured in tons per hour (t/h).                                         |
| ambient_temp_c        | FLOAT     | Ambient environmental temperature surrounding the plant, measured in degrees Celsius (°C). |
| product_yield_tons    | FLOAT     | Quantity of finished product produced during the operation, measured in tons.              |
| energy_intensity      | FLOAT     | Energy consumed per unit of product produced, representing overall process efficiency.     |

Star Schema Summary

| Table                      | Type      | Purpose                                                                          |
| -------------------------- | --------- | -------------------------------------------------------------------------------- |
| gold.dim_time              | Dimension | Stores time attributes for time-based analysis.                                  |
| gold.dim_unit              | Dimension | Stores petrochemical processing unit information.                                |
| gold.dim_catalyst          | Dimension | Stores catalyst information.                                                     |
| gold.fact_plant_operations | Fact      | Stores operational measurements and production metrics linked to all dimensions. |
