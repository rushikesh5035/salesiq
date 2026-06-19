/*
===============================================================================
QUALITY CHECKS: GOLD LAYER
===============================================================================

Purpose:
    Validate Gold layer dimensions and fact table integrity.

Checks Performed:
1. Customer Dimension Validation.
2. Product Dimension Validation.
3. Fact Table Validation.
4. Customer Foreign Key Integrity.
5. Product Foreign Key Integrity.

Expected Result:
    * No orphan customer keys.
    * No orphan product keys.
    * Fact table joins successfully to all dimensions.
===============================================================================
*/

------------------------------------------------------------
-- CUSTOMER DIMENSION
------------------------------------------------------------

SELECT *
FROM gold.dim_customers;

------------------------------------------------------------
-- PRODUCT DIMENSION
------------------------------------------------------------

SELECT *
FROM gold.dim_products;

------------------------------------------------------------
-- FACT TABLE
------------------------------------------------------------

SELECT *
FROM gold.fact_sales;

------------------------------------------------------------
-- CUSTOMER FOREIGN KEY INTEGRITY
------------------------------------------------------------

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL;

------------------------------------------------------------
-- PRODUCT FOREIGN KEY INTEGRITY
------------------------------------------------------------

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL;