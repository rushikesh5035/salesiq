/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
*/

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
BEGIN
    batch_start_time := clock_timestamp();

    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Loading Silver Layer';
    RAISE NOTICE '============================================================';

    ----------------------------------------------------------------
    -- CRM CUSTOMER INFORMATION
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.crm_cust_info';

    TRUNCATE TABLE silver.crm_cust_info;

    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname),
        TRIM(cst_lastname),

        CASE UPPER(TRIM(cst_marital_status))
            WHEN 'S' THEN 'Single'
            WHEN 'M' THEN 'Married'
            ELSE 'n/a'
        END,

        CASE UPPER(TRIM(cst_gndr))
            WHEN 'F' THEN 'Female'
            WHEN 'M' THEN 'Male'
            ELSE 'n/a'
        END,

        cst_create_date

    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag_last = 1;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);


    ----------------------------------------------------------------
    -- CRM PRODUCT INFORMATION
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.crm_prod_info';

    TRUNCATE TABLE silver.crm_prod_info;

    INSERT INTO silver.crm_prod_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,

        REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,

        SUBSTRING(prd_key,7,LENGTH(prd_key)) AS prd_key,

        TRIM(prd_nm),

        COALESCE(prd_cost,0),

        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END,

        CAST(prd_start_dt AS DATE),

        (
            LEAD(prd_start_dt)
            OVER(
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ) - INTERVAL '1 day'
        )::DATE

    FROM bronze.crm_prod_info;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);

    ----------------------------------------------------------------
    -- CRM SALES DETAILS
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.crm_sales_details';

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

        CASE
            WHEN sls_order_dt = 0
              OR LENGTH(sls_order_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_order_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_ship_dt = 0
              OR LENGTH(sls_ship_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_ship_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_due_dt = 0
              OR LENGTH(sls_due_dt::TEXT) <> 8
            THEN NULL
            ELSE TO_DATE(sls_due_dt::TEXT,'YYYYMMDD')
        END,

        CASE
            WHEN sls_sales IS NULL
              OR sls_sales <= 0
              OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
              OR sls_price <= 0
            THEN ABS(
                sls_sales / NULLIF(sls_quantity,0)
            )
            ELSE ABS(sls_price)
        END

    FROM bronze.crm_sales_details;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);
    

    ----------------------------------------------------------------
    -- ERP CUSTOMER INFORMATION
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.erp_cust_az12';

    TRUNCATE TABLE silver.erp_cust_az12;

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%'
            THEN SUBSTRING(cid,4,LENGTH(cid))
            ELSE cid
        END,

        CASE
            WHEN bdate > CURRENT_DATE
            THEN NULL
            ELSE bdate
        END,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F','FEMALE')
                THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M','MALE')
                THEN 'Male'
            ELSE 'n/a'
        END

    FROM bronze.erp_cust_az12;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);

    ----------------------------------------------------------------
    -- ERP LOCATION INFORMATION
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.erp_loc_a101';

    TRUNCATE TABLE silver.erp_loc_a101;

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT
        REPLACE(cid,'-',''),

        CASE
            WHEN TRIM(cntry) = 'DE'
                THEN 'Germany'
            WHEN TRIM(cntry) IN ('US','USA')
                THEN 'United States'
            WHEN TRIM(cntry) = ''
                 OR cntry IS NULL
                THEN 'n/a'
            ELSE TRIM(cntry)
        END

    FROM bronze.erp_loc_a101;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);

    ----------------------------------------------------------------
    -- ERP PRODUCT CATEGORY INFORMATION
    ----------------------------------------------------------------

    start_time := clock_timestamp();

    RAISE NOTICE '>> Loading Table: silver.erp_px_cat_g1v2';

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT
        id,
        TRIM(cat),
        TRIM(subcat),
        TRIM(maintenance)
    FROM bronze.erp_px_cat_g1v2;

    end_time := clock_timestamp();

    RAISE NOTICE '>> Duration: % sec',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);
    

    ----------------------------------------------------------------
    -- BATCH SUMMARY
    ----------------------------------------------------------------

    batch_end_time := clock_timestamp();

    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Silver Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (batch_end_time - batch_start_time)), 2);
    RAISE NOTICE '============================================================';

EXCEPTION
    WHEN OTHERS THEN

        RAISE NOTICE '============================================================';
        RAISE NOTICE 'ERROR OCCURRED DURING SILVER LOAD';
        RAISE NOTICE 'ERROR MESSAGE: %', SQLERRM;
        RAISE NOTICE '============================================================';

        RAISE;
END;
$$;