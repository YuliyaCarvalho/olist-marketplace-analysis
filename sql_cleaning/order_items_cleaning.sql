-- OLIST DATA CLEANING & EDA
-- Table: order_items


-- 1. Initial Cleaning: Whitespace Trimming and Case Normalisation
-- Removing leading/trailing spaces and converting IDs to lowercase to ensure JOIN consistency

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_items` AS
SELECT
    LOWER(TRIM(order_id)) AS order_id,
    order_item_id,
    LOWER(TRIM(product_id)) AS product_id,
    LOWER(TRIM(seller_id)) AS seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`;


-- 2. NULL Value Profiling
-- Checking all columns for missing values

SELECT
    COUNTIF(order_id IS NULL) AS null_order_id,
    COUNTIF(order_item_id IS NULL) AS null_order_item_id,
    COUNTIF(product_id IS NULL) AS null_product_id,
    COUNTIF(seller_id IS NULL) AS null_seller_id,
    COUNTIF(shipping_limit_date IS NULL) AS null_shipping_limit_date,
    COUNTIF(price IS NULL) AS null_price,
    COUNTIF(freight_value IS NULL) AS null_freight_value
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`;


-- 3. Primary Key Validation
-- Confirming that the composite key (order_id, order_item_id) is unique

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS dup_count
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`
GROUP BY
    order_id,
    order_item_id
HAVING dup_count > 1;


-- 4. Referential Integrity: Mapping to Orders Table
-- Checking if any items reference orders missing from the orders table

SELECT
    COUNT(*) AS missing_orders
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items` AS i
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
USING(order_id)
WHERE o.order_id IS NULL;


-- 5. Identifying Orders Without Items
-- Quantifying orders that never reached line-item registration

SELECT
    COUNT(*) AS orders_without_items
FROM `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.order_items` AS i
USING(order_id)
WHERE i.order_id IS NULL;


-- 6. Distribution of Items per Order (EDA)
-- Understanding the typical basket size of customers

WITH order_item_count AS (

    SELECT
        order_id,
        COUNT(*) AS num_items
    FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`
    GROUP BY order_id

),

total_orders AS (

    SELECT
        COUNT(*) AS total_orders
    FROM `olist-project-yuliacarvalho.Olist_datasets.orders`

)

SELECT
    oic.num_items,
    COUNT(*) AS num_orders,
    ROUND(COUNT(*) / t.total_orders * 100, 3) AS pct_orders

FROM order_item_count AS oic
CROSS JOIN total_orders AS t
GROUP BY
    oic.num_items,
    t.total_orders
ORDER BY oic.num_items;


-- 7. Analyzing Status of Item-less Orders
-- Confirming that item-less orders are mostly cancelled or unavailable

SELECT
    o.order_status,
    COUNT(o.order_id) AS orders_count,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_no_item_orders
FROM `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.order_items` AS i
USING(order_id)
WHERE i.order_id IS NULL
GROUP BY o.order_status
ORDER BY orders_count DESC;


-- 8. Shipping Limit Chronology Check
-- Verifying that shipping deadlines occur after purchase timestamps

SELECT
    MIN(shipping_limit_date) AS earliest_limit,
    MAX(shipping_limit_date) AS latest_limit,

    COUNTIF(shipping_limit_date < order_purchase_timestamp) AS impossible_limits
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`
JOIN `olist-project-yuliacarvalho.Olist_datasets.orders`
USING(order_id);


-- 9. Advanced Diagnostic: Category-Level P99 Outlier Flagging
-- Identifying unrealistic shipping deadlines using a category-level 99th percentile threshold

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_items_enriched` AS

WITH shipping_windows AS (

    SELECT
        oi.*,
        DATE_DIFF(
            DATE(oi.shipping_limit_date),
            DATE(o.order_purchase_timestamp),
            DAY
        ) AS shipping_limit_days,
        p.product_category_eng AS product_category

    FROM `olist-project-yuliacarvalho.Olist_datasets.order_items` AS oi
    JOIN `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
    USING(order_id)
    LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.products_final` AS p
    USING(product_id)
    ),

category_p99 AS (

    SELECT
        product_category,
        APPROX_QUANTILES(shipping_limit_days, 100)[OFFSET(99)] AS shipping_limit_p99
    FROM shipping_windows
    GROUP BY product_category
)

SELECT
    sw.*,
    cp.shipping_limit_p99,

    CASE
        WHEN sw.shipping_limit_days > cp.shipping_limit_p99 THEN 1
        ELSE 0
    END AS shipping_limit_flag_p99

FROM shipping_windows AS sw
LEFT JOIN category_p99 AS cp
USING(product_category);


-- 10. Monetary Value Sanity Check
-- Auditing price and freight columns for negative or zero values

SELECT
    SUM(CASE WHEN price < 0 THEN 1 ELSE 0 END) AS negative_price,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight,
    COUNTIF(price = 0) AS zero_price_rows,
    COUNTIF(freight_value = 0) AS zero_freight_rows
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`;


-- 11. Free Shipping Concentration (Sellers)
-- Identifying sellers who frequently offer free shipping

SELECT
    seller_id,
    COUNT(*) AS total_items,
    SUM(
        CASE
            WHEN freight_value = 0 THEN 1
            ELSE 0
        END
    ) AS free_items,

    ROUND(100 * SUM(
            CASE
                WHEN freight_value = 0 THEN 1
                ELSE 0
            END) / COUNT(*), 1) AS free_shipping_pct
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items`
GROUP BY seller_id
HAVING free_items > 0
ORDER BY free_items DESC;


-- 12. Final Analytical Table: order_items_final
-- Creating the final dataset enriched with review scores

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_items_final` AS
SELECT
    oi.*,
    r.review_score
FROM `olist-project-yuliacarvalho.Olist_datasets.order_items_enriched` AS oi
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.order_review_final` AS r
USING(order_id);