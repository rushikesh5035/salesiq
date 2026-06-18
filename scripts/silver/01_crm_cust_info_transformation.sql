/*
===============================================================================
Transformation: CRM Customer Information
===============================================================================
*/


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

	-- Remove unwanted spaces
    TRIM(cst_firstname) AS cst_firstname,

    -- Remove unwanted spaces
    TRIM(cst_lastname) AS cst_lastname,
	
	-- Standardize marital status values
    CASE UPPER(TRIM(cst_marital_status))
        WHEN 'S' THEN 'Single'
        WHEN 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    -- Standardize gender values
    CASE UPPER(TRIM(cst_gndr))
        WHEN 'F' THEN 'Female'
        WHEN 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gndr,
	
	cst_create_date
FROM (
	SELECT *,
		-- Remove duplicate customer records and Keep only the most recent customer record
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
	FROM bronze.crm_cust_info
	-- Remove records with NULL customer IDs
    WHERE cst_id IS NOT NULL
) t 
-- Select latest customer record
WHERE flag_last = 1;