/*
=============================================================================== 
-- Transformation: ERP Product Category Information =============================================================================== 
Purpose: Load and standardize product category reference data. 

Applied Transformations: 
    1. Preserve category hierarchy. 
    2. Preserve subcategory information. 
    3. Preserve maintenance attributes. 
Expected Result: 
    * Clean and standardized product category reference data. 
=============================================================================== 
*/

TRUNCATE TABLE silver.erp_px_cat_g1v2;

INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,

    TRIM(cat) AS cat,

    TRIM(subcat) AS subcat,

    TRIM(maintenance) AS maintenance
FROM bronze.erp_px_cat_g1v2;