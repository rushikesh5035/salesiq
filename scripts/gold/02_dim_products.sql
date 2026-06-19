/*
===============================================================================
Dimension: Products
===============================================================================

Purpose:
    Creates the product dimension by combining CRM product
    information with ERP product category data.

Business Rules:
1. Use only active products.
2. Exclude historical product versions.
3. Enrich products with category information.
4. Generate surrogate product keys.

Result:
    One record per active product for analytical reporting.
===============================================================================
*/

DROP VIEW IF EXISTS gold.dim_products;

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY pn.prd_start_dt, pn.prd_key
    ) AS product_key,

    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,

    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,

    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date

FROM silver.crm_prod_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pn.cat_id = pc.id

WHERE pn.prd_end_dt IS NULL;