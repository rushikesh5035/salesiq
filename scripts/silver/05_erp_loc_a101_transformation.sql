/* 
=============================================================================== 
-- Transformation: ERP Location Information =============================================================================== 
Purpose: Clean and standardize customer location data. 

Applied Transformations: 
    1. Remove special characters from customer IDs. 
    2. Standardize country codes and country names. 
    3. Replace missing country values with 'n/a'. 
Expected Result: 
    * Standardized customer identifiers. 
    * Consistent country names. 
=============================================================================== 
*/

TRUNCATE TABLE silver.erp_loc_a101;

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,

    CASE
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry
FROM bronze.erp_loc_a101;
