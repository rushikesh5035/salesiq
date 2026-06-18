/*
Transformation: CRM Sales Details

Purpose: Clean and standardize sales transaction data before loading into the Silver layer.

Applied Transformations:
    Validate and convert order dates.
    Validate and convert ship dates.
    Validate and convert due dates.
    Recalculate invalid sales amounts.
    Convert negative prices to positive values.
    Recalculate missing or invalid prices.
    Preserve customer, product and order business keys.
*/


TRUNCATE TABLE silver.crm_sales_details;

INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Validate and convert Order Date
    CASE
        WHEN sls_order_dt = 0
        OR LENGTH(sls_order_dt::TEXT) <> 8
        THEN NULL
        ELSE TO_DATE(sls_order_dt::TEXT, 'YYYYMMDD')
    END AS sls_order_dt,

    -- Validate and convert Ship Date
    CASE
        WHEN sls_ship_dt = 0
        OR LENGTH(sls_ship_dt::TEXT) <> 8
        THEN NULL
        ELSE TO_DATE(sls_ship_dt::TEXT, 'YYYYMMDD')
    END AS sls_ship_dt,

    -- Validate and convert Due Date
    CASE
        WHEN sls_due_dt = 0
        OR LENGTH(sls_due_dt::TEXT) <> 8
        THEN NULL
        ELSE TO_DATE(sls_due_dt::TEXT, 'YYYYMMDD')
    END AS sls_due_dt,

    -- Recalculate invalid sales amounts
    CASE
        WHEN sls_sales IS NULL
        OR sls_sales <= 0
        OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    sls_quantity,

    -- Recalculate invalid prices and standardize negatives
    CASE
        WHEN sls_price IS NULL
        OR sls_price <= 0
        THEN ABS(
            sls_sales / NULLIF(sls_quantity, 0)
        )
        ELSE ABS(sls_price)
    END AS sls_price
    
FROM bronze.crm_sales_details;