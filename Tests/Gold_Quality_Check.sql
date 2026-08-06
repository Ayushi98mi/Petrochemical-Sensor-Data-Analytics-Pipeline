/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer.

    These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of the Star Schema relationships.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- =============================================================================
-- Checking 'gold.dim_unit'
-- =============================================================================

-- Check uniqueness of Unit Key
-- Expectation: No results

SELECT
    unit_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_unit
GROUP BY unit_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold.dim_catalyst'
-- =============================================================================

-- Check uniqueness of Catalyst Key
-- Expectation: No results

SELECT
    catalyst_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_catalyst
GROUP BY catalyst_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold.dim_time'
-- =============================================================================

-- Check uniqueness of Time Key
-- Expectation: No results

SELECT
    time_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_time
GROUP BY time_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold.fact_plant_operations'
-- =============================================================================

-- Check referential integrity between fact and dimensions
-- Expectation: No results

SELECT *
FROM gold.fact_plant_operations f
LEFT JOIN gold.dim_time t
    ON f.time_key = t.time_key
LEFT JOIN gold.dim_unit u
    ON f.unit_key = u.unit_key
LEFT JOIN gold.dim_catalyst c
    ON f.catalyst_key = c.catalyst_key
WHERE
    t.time_key IS NULL
    OR u.unit_key IS NULL
    OR c.catalyst_key IS NULL;


---Fact table row count check


SELECT COUNT(*) AS silver_rows
FROM silver.petrochemical_operations;

SELECT COUNT(*) AS fact_rows
FROM gold.fact_plant_operations;

-- Expected: Same row count as Silver table

---Dimension row count check
SELECT COUNT(DISTINCT Unit_Name)
FROM silver.petrochemical_operations;

SELECT COUNT(*)
FROM gold.dim_unit;

SELECT COUNT(DISTINCT Catalyst_Type)
FROM silver.petrochemical_operations;

SELECT COUNT(*)
FROM gold.dim_catalyst;

SELECT COUNT(DISTINCT Time_stamp)
FROM silver.petrochemical_operations;

SELECT COUNT(*)
FROM gold.dim_time;

---Expected:

---Distinct Unit_Name = Rows in gold.dim_unit
--Distinct Catalyst_Type = Rows in gold.dim_catalyst
--Distinct Time_stamp = Rows in gold.dim_time
