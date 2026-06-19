/*
===============================================================================
Dimension: Customers
===============================================================================

Purpose:
    Creates the customer dimension by combining CRM customer
    information with ERP demographic and location data.

Business Rules:
1. CRM customer information is the primary source.
2. CRM gender values take precedence over ERP gender values.
3. ERP location data provides customer country.
4. ERP customer data provides birthdate information.
5. Generate surrogate customer keys.

Result:
    One record per customer for analytical reporting.
===============================================================================
*/

DROP VIEW IF EXISTS gold.dim_customers;

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,

    CASE
        WHEN ci.cst_gndr <> 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS gender,

    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date

FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
    ON ci.cst_key = la.cid;