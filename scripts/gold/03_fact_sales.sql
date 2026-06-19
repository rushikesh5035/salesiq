/*
===============================================================================
Fact Table: Sales
===============================================================================

Purpose:
    Creates the sales fact view by linking sales transactions
    with customer and product dimensions.

Business Rules:
1. Join sales transactions to customer dimension.
2. Join sales transactions to product dimension.
3. Preserve transactional measures.
4. Preserve transactional dates.

Result:
    Central fact table supporting sales analytics and reporting.
===============================================================================
*/

DROP VIEW IF EXISTS gold.fact_sales;

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num AS order_number,

    pr.product_key,
    cu.customer_key,

    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,

    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS sales_quantity,
    sd.sls_price AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON sd.sls_prd_key = pr.product_number

LEFT JOIN gold.dim_customers cu
    ON sd.sls_cust_id = cu.customer_id;