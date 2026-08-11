/*
===============================================================================
Dimensions Exploration
===============================================================================
Purpose:
    - To explore the structure of dimension tables.

SQL Functions Used:
    - DISTINCT, ORDER BY
===============================================================================
*/

-- Retrieve the list of unique plant units
SELECT DISTINCT unit_name
FROM gold.dim_unit
ORDER BY unit_name;

-- Retrieve the list of unique catalyst types
SELECT DISTINCT catalyst_type
FROM gold.dim_catalyst
ORDER BY catalyst_type;

-- Explore the structure of the time dimension (years, months, shifts covered)
SELECT DISTINCT year, month_name, shift
FROM gold.dim_time
ORDER BY year, month_name;
