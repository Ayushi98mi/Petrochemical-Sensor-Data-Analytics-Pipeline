# Petrochemical Sensor Data Analytics Pipeline

End-to-end data engineering & analytics project on petrochemical plant sensor data using Medallion Architecture (Bronze-Silver-Gold). Includes SQL-based ETL and business analytics, Python for statistical analysis, and a Power BI dashboard for reporting.

## Key Findings

- **Reactor pressure (r = 0.779) and feedstock flow (r = 0.625) are the strongest, statistically validated drivers of product yield** (Pearson correlation, p < 0.001 for both).
- **Vibration level (r = −0.381) and energy intensity (r = −0.819)** show strong secondary associations with yield — high vibration and high energy intensity are linked to lower production output.
- **Catalyst type, production unit, and shift show no statistically significant effect on yield** (one-way ANOVA: p = 0.851, 0.539, and 0.155 respectively), despite small numerical differences in mean yield across these groups.
- The best-observed operating state achieves **93.13 tons of yield at only 2.35 energy intensity**, proving that high yield and low energy consumption are simultaneously achievable — this defines a target operating regime.
- 338 anomalous observations were identified (IQR-based), which on average show notably lower yield and higher energy intensity than normal operation.

## Data Source

- **Dataset:** Petrochemical Process Optimization & Maintenance
- **Source:** Kaggle
- **Records:** 10,000+
- **Format:** CSV
- **Domain:** Petrochemical Plant Operations

## Tech Stack

- **Database:** SQL Server
- **Languages:** SQL, Python
- **Python Libraries:** pandas, numpy, matplotlib, seaborn, scipy, sqlalchemy
- **Visualization / BI:** Power BI *(planned)*
- **Tools:** Git & GitHub, Draw.io (Architecture & Star Schema)

## Data Architecture

<img width="1191" height="771" alt="DATA_ARCHITECTURE drawio" src="https://github.com/user-attachments/assets/495da2bb-2fcf-446f-a33a-699aede2e416" />

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

## Data Flow Diagram

<img width="891" height="384" alt="FLOW_DIAGRAM drawio" src="https://github.com/user-attachments/assets/91c291cb-b876-4dce-a8f6-f107ca9eeca7" />

## Data Quality Checks (Bronze Layer)

Before moving data to the Silver layer, the following quality checks were performed on the raw Bronze data:

### 1. Duplicate Check
Checked for exact duplicate records based on the combination of `Timestamp`, `Unit_Name`, and `Catalyst_Type` (these three columns together define a unique operational event).

**Result:** 2 duplicate combinations found on initial raw-text comparison (a 3rd hidden duplicate was later discovered once Timestamp and Unit_Name were standardized during cleaning):
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
- No numeric column should contain negative values, except `Ambient_Temp_C` (which can legitimately be negative in winter conditions)

**Result:**
- `Sensor_Health_Index`: 6 rows out of range (0–1), including 2 negative values
- `Valve_Opening_Percent`: 0 rows out of range — no issue found
- Negative values across all other columns: 5 total (3 in `Catalyst_Age_Days`, 2 in `Sensor_Health_Index`)

### 4. Text Standardization Check (Case & Spacing)
Checked `Unit_Name` and `Catalyst_Type` for leading/trailing spaces and case inconsistencies (e.g. `Ethylene_Plant_01` vs `ETHYLENE_plant_01`), using `TRIM()` for spacing and a `VARBINARY` cast for case-sensitive comparison, since SQL Server is case-insensitive by default.

**Result:**
- Spacing: 0 issues found
- Case inconsistencies: 8 raw variants found across 3 real Unit_Name values, and similar variants in `Catalyst_Type`

### Resolution
These issues were addressed in the Silver layer:
- **Duplicates** were removed using a `ROW_NUMBER()` window function, partitioned on the *standardized* (case-normalized, converted) versions of Timestamp, Unit_Name, and Catalyst_Type — not the raw values — to ensure hidden duplicates were also caught.
- **NULL and out-of-range values** were imputed using Unit-wise averages, calculated only from valid, in-range readings (invalid values were excluded from the average calculation itself).
- **Text fields** were standardized using `UPPER(TRIM())` to merge all case/spacing variants into a single consistent value per category.

## Gold Layer

The Gold layer follows a Star Schema consisting of:

- `dim_time`
- `dim_unit`
- `dim_catalyst`
- `fact_plant_operations`

### Star Schema
<img width="947" height="1052" alt="Star_Schema drawio" src="https://github.com/user-attachments/assets/95de89c7-4999-4629-9dca-8e7aee53b55c" />

---

## Python Analysis

The Gold layer data was imported into Python for exploratory, correlation, and statistical analysis. Full analysis and code: [`PYTHON_ANALYSIS/merge.ipynb`](PYTHON_ANALYSIS/merge.ipynb)

### Approach
1. Exploratory Data Analysis (distributions, production performance by unit/catalyst/shift/time)
2. Correlation analysis between yield and operating conditions
3. Catalyst aging effect analysis
4. Deep-dive root-cause analysis on the strongest drivers (pressure, flow, vibration, shift)
5. Anomaly detection (IQR-based)
6. Inferential statistical validation (Pearson significance testing, one-way ANOVA)
7. Correlation heatmap across all numeric variables

### Results — Descriptive vs. Inferential Statistics

| Factor | Type | Descriptive Result | Inferential Test | Test Result | Statistically Significant? |
|---|---|---|---|---|---|
| Reactor Pressure | Continuous | r = 0.779 (strong positive) | Pearson correlation | p < 0.001 | Yes |
| Feedstock Flow | Continuous | r = 0.625 (moderate-strong positive) | Pearson correlation | p < 0.001 | Yes |
| Vibration Level | Continuous | r = −0.381 (moderate negative) | Pearson correlation | p < 0.001 | Yes |
| Energy Intensity | Continuous | r = −0.819 (strong negative) | Pearson correlation | p < 0.001 | Yes |
| Catalyst Type | Categorical | Mean diff ~0.17 tons (Iron 80.27, Cobalt 80.27, Platinum 80.10) | One-way ANOVA | F = 0.162, p = 0.851 | No |
| Production Unit | Categorical | Mean diff ~0.38 tons (Ethylene 80.38, Ammonia 80.26, Methanol 80.00) | One-way ANOVA | F = 0.619, p = 0.539 | No |
| Shift | Categorical | Mean diff ~0.59 tons (Morning 80.60, Night 80.04, Evening 80.01) | One-way ANOVA | F = 1.862, p = 0.155 | No |
| Catalyst Age | Continuous | r = 0.008 with yield (negligible) | Pearson correlation | No meaningful relationship | No |

### Combined Interpretation

The inferential results directly complement and statistically validate the descriptive findings. Where descriptive statistics suggested that pressure, flow, vibration, and energy intensity were the dominant factors influencing yield, inferential testing confirmed these relationships are statistically significant and not attributable to chance. Where descriptive statistics showed only minor differences across catalyst type, unit, and shift, inferential testing confirmed that these differences do not represent genuine effects.

Together, this two-stage analysis — descriptive exploration followed by inferential validation — provides strong statistical evidence that **reactor pressure and feedstock flow are the primary controllable drivers of product yield**, while vibration and energy intensity serve as important secondary indicators of process efficiency and equipment health. Catalyst type, production unit, and shift, despite showing small numerical differences, do not have a statistically meaningful independent effect on yield.

### Correlation Heatmap

A correlation heatmap was generated to visualize relationships across all numeric variables. It confirmed the key drivers of yield identified above, while also revealing:
- **Pressure and feedstock flow are independent of each other** (r ≈ 0.00), meaning they contribute separately to yield rather than overlapping in explanatory power.
- A moderate negative correlation between **pressure and vibration** (r = −0.49) — higher pressure operation is associated with somewhat lower equipment vibration.
- A moderate-strong negative correlation between **pressure and energy intensity** (r = −0.66) — higher-pressure operation tends to coincide with better energy efficiency, consistent with the high-yield/low-energy operating state identified in the analysis.

## Future Recommendations

1. **Pressure Optimization** — Operate around the historically favourable pressure range identified in this analysis rather than maximizing pressure blindly, while respecting safety, equipment, and cost constraints.
2. **Feedstock Flow Optimization** — Maintain adequate flow to support yield, but avoid increasing flow further once the marginal yield benefit diminishes relative to feedstock cost.
3. **Vibration as an Early-Warning Indicator** — Yield deteriorates sharply beyond ~5.2 mm/s vibration, alongside rising energy intensity. Use high vibration as a maintenance/process-health trigger.
4. **Target the High-Yield, Low-Energy Operating Regime** — The best-observed state (93.13 tons yield at 2.35 energy intensity) shows this is achievable and should be used as a benchmark.
5. **Prioritize Statistically Validated Levers** — Focus optimization effort on pressure, flow, and vibration; catalyst type, unit, and shift showed no statistically significant independent effect on yield.
6. **Review, Don't Eliminate, Low-Impact Variables** — A weak or non-significant statistical association does not imply operational irrelevance (e.g. sensor health index has no correlation with yield but remains essential monitoring infrastructure). Review the cost and necessity of such variables separately.
7. **Validate Experimentally** — This analysis is observational; correlation and statistical significance establish association, not causation. Recommended operating ranges should be validated through controlled trials before implementation.

**Overall goal:** Maximize economically useful yield at minimum energy and feedstock cost — not simply maximum yield.

## Data Catalog

Detailed description of all Gold Layer tables and columns is available here: [`docs/data_catalog.md`](docs/data_catalog.md)

## About the Author

**Ayushi Bajpai**
B.Tech, Chemical Engineering — Indian Institute of Technology, Jammu (2023–2027)

I'm a Chemical Engineering undergraduate exploring the intersection of process engineering and data analytics. This project reflects that interest — applying data pipeline design, SQL, and statistical analysis to a real industrial (petrochemical) context, rather than a generic dataset.

- GitHub: [Ayushi98mi](https://github.com/Ayushi98mi)
- LinkedIn: *(https://www.linkedin.com/in/ayushi-bajpai-49587b292/)*
- Email: ayushib306@gmail.com
