# /*
===============================================================================
-- Transformation: CRM Product Information
===============================================================================

Purpose: Clean and standardize product master data before loading into the Silver layer.

Applied Transformations:
    1. Extract category identifier from product key.
    2. Derive clean product key by removing category prefix.
    3. Remove unwanted spaces from product names.
    4. Replace NULL product costs with 0.
    5. Standardize product line codes into readable values.
    6. Convert product start dates to DATE format.
    7. Rebuild product history using LEAD() to calculate end dates.

Expected Result:
    * Clean product master data.
    * Standardized product categories and product lines.
    * Historical product records with valid date ranges.
====================================================
*/


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
	
	-- Cetegory ID
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, 

	-- Product KEy
	SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key, 

	-- Product name
	TRIM(prd_nm) AS prd_nm,

	-- Handle NULL Cost
	COALESCE(prd_cost, 0) as prd_cost,

	-- Product Line Standardization
	CASE UPPER(TRIM(prd_line)) 
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END as prd_line,

	-- Start Date
	CAST(prd_start_dt AS DATE) AS prd_start_dt,

	-- End Date
	(
		LEAD(prd_start_dt) OVER (
			PARTITION BY prd_key 
			ORDER BY prd_start_dt
		)- INTERVAL '1 day'
	)::date AS prd_end_dt
FROM bronze.crm_prod_info;


/*
===============================================================================
Validation After Load
===============================================================================
*/

-- SELECT *
-- FROM silver.crm_prod_info
-- LIMIT 100;