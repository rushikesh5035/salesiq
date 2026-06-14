# /*

# Stored Procedure: Load Bronze Layer (Source -> Bronze)

Purpose:
Loads CRM and ERP source data from CSV files into Bronze tables.

Process:
1. Truncates existing Bronze tables.
2. Loads source CSV files using PostgreSQL COPY.
3. Logs execution duration.
4. Provides error handling and execution summary.

Usage:
CALL bronze.load_bronze();

===============================================================================
*/

-- CREATE STORE PROCEDURE TO LOAD DATA
CREATE OR REPLACE PROCEDURE bronze.load_bronze()
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
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '============================================================';

	------------------------------------------------------------
    -- CRM TABLES
    ------------------------------------------------------------
	RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------------------';
	
	-- CRM CUSTOMER
	start_time := clock_timestamp();
	
	RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE TABLE bronze.crm_cust_info;
		
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
	COPY bronze.crm_cust_info
	FROM 'E:/salesiq/datasets/source_crm/cust_info.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);
	
	end_time := clock_timestamp();
	
	RAISE NOTICE '>> Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);
	
	RAISE NOTICE '------------------------------------------------------------';
    
	-- CRM PRODUCT
	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_prod_info';
	TRUNCATE TABLE bronze.crm_prod_info;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_prod_info';
	COPY bronze.crm_prod_info
	FROM 'E:/salesiq/datasets/source_crm/prd_info.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);

	end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)),2);

	RAISE NOTICE '------------------------------------------------------------';
	
    -- CRM SALES
	start_time := clock_timestamp();
	
	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
	TRUNCATE TABLE bronze.crm_sales_details;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
	COPY bronze.crm_sales_details
	FROM 'E:/salesiq/datasets/source_crm/sales_details.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);

	end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)),2);

	RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'CRM Tables Loaded Successfully';
    RAISE NOTICE '------------------------------------------------------------';

	------------------------------------------------------------
    -- ERP TABLES
    ------------------------------------------------------------
	RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------------------';

	-- ERP LOCATION
	start_time := clock_timestamp();
	
	RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
	TRUNCATE TABLE bronze.erp_loc_a101;

	RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
	COPY bronze.erp_loc_a101
	FROM 'E:/salesiq/datasets/source_erp/LOC_A101.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);

	end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)),2);

	RAISE NOTICE '------------------------------------------------------------';

    -- ERP CUSTOMER	
	start_time := clock_timestamp();
	
	RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
	TRUNCATE TABLE bronze.erp_cust_az12;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
	COPY bronze.erp_cust_az12
	FROM 'E:/salesiq/datasets/source_erp/CUST_AZ12.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);
	
	end_time := clock_timestamp();

    RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)),2);
	
	RAISE NOTICE '------------------------------------------------------------';
	
    -- ERP PX CAT	
	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
	TRUNCATE TABLE bronze.erp_px_cat_g1v2;

	RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
	COPY bronze.erp_px_cat_g1v2
	FROM 'E:/salesiq/datasets/source_erp/PX_CAT_G1V2.csv'
	WITH (
	    FORMAT csv,
	    HEADER true
	);

	end_time := clock_timestamp();

	RAISE NOTICE '>> Load Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (end_time - start_time)), 2);

	RAISE NOTICE '------------------------------------------------------------';
    RAISE NOTICE 'ERP Tables Loaded Successfully';
    RAISE NOTICE '------------------------------------------------------------';
	
    ----------------------------------------------------------------
    -- BATCH SUMMARY
    ----------------------------------------------------------------
    batch_end_time := clock_timestamp();

    RAISE NOTICE '============================================================';
    RAISE NOTICE 'Bronze Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: % seconds',
        ROUND(EXTRACT(EPOCH FROM (batch_end_time - batch_start_time)), 2);
    RAISE NOTICE '============================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '===========================================';
        RAISE NOTICE 'ERROR OCCURRED DURING BRONZE LOAD';
        RAISE NOTICE 'ERROR MESSAGE: %', SQLERRM;
        RAISE NOTICE '===========================================';
        RAISE;
END;
$$;