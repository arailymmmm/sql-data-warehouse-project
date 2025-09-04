/*
===============================================================================
Quality Checks - Gold Layer (MySQL Version)
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- Check for NULL Customer Keys
SELECT *
FROM gold.dim_customers
WHERE customer_key IS NULL;

-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Check for NULL Product Keys
SELECT *
FROM gold.dim_products
WHERE product_key IS NULL;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Validate Referential Integrity between Fact and Dimension Tables
-- Expectation: No results (all foreign keys must match corresponding dimension keys)
SELECT 
    f.sales_id,
    f.customer_key,
    f.product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL 
   OR p.product_key IS NULL;

-- ====================================================================
-- Additional Checks
-- ====================================================================

-- Count summary by table to validate row volume
SELECT 'dim_customers' AS table_name, COUNT(*) AS row_count FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM gold.fact_sales;

-- Validate that fact_sales has no NULL surrogate keys
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL OR product_key IS NULL;

-- Optional: Detect Negative or Zero Sales Amounts
SELECT *
FROM gold.fact_sales
WHERE total_sales <= 0;
