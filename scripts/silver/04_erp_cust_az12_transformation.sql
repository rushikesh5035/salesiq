/* 
=============================================================================== 
-- Transformation: ERP Customer Information 
=============================================================================== 
Purpose: Clean and standardize customer demographic data. 
Applied Transformations: 
    1. Remove 'NAS' prefix from customer identifiers. 
    2. Replace future birth dates with NULL. 
    3. Standardize gender values. 
    4. Preserve valid customer attributes. 

Expected Result: 
    * Standardized customer identifiers. 
    * Valid birth dates. 
    * Consistent gender values. 
=============================================================================== 
*/

TRUNCATE TABLE silver.erp_cust_az12;

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,

    CASE
        WHEN bdate > CURRENT_DATE THEN NULL
        ELSE bdate
    END AS bdate,

    CASE
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'n/a'
    END AS gen

FROM bronze.erp_cust_az12;