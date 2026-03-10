-- OLIST DATA CLEANING & EDA
-- Table: products


-- 1. NULL Value Profiling
-- Checking for missing values across category names and physical dimensions

SELECT
    COUNT(*) AS total_rows,
    COUNTIF(product_category_name IS NULL) AS product_category_name_nulls,
    COUNTIF(product_name_length IS NULL) AS product_name_length_nulls,
    COUNTIF(product_description_length IS NULL) AS product_description_length_nulls
FROM `olist-project-yuliacarvalho.Olist_datasets.products`;


-- 2. Category Diversity Audit
-- Counting distinct Portuguese category names to understand assortment breadth

SELECT
    COUNT(DISTINCT product_category_name) AS num_prod_cat
FROM `olist-project-yuliacarvalho.Olist_datasets.products`;


-- 3. Investigation of Uncategorized Products
-- Isolating the volume of products missing a category label

SELECT
    DISTINCT product_category_name,
    COUNT(*) AS num_prod_cat
FROM `olist-project-yuliacarvalho.Olist_datasets.products`
WHERE product_category_name IS NULL
GROUP BY product_category_name;


-- 4. Translation and Typo Correction
-- Joining with the translation table, trimming whitespace, and fixing known gaps in English category labels
-- Note: 'pc_gamer' and 'portateis_cozinha...' were identified as missing from the translation table

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.products_merged` AS
SELECT
    p.* EXCEPT(product_category_name),
    TRIM(t.product_category_eng) AS product_category_eng
FROM `olist-project-yuliacarvalho.Olist_datasets.products` AS p
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.prod_cat_name_translation` AS t
    ON p.product_category_name = t.product_category_pt;


-- 5. Physical Dimension Consistency Check
-- Identifying products missing all dimension data (weight, length, height, and width)

SELECT
    COUNT(*) AS products_missing_all_dimensions
FROM `olist-project-yuliacarvalho.Olist_datasets.products`
WHERE product_weight_g IS NULL
    AND product_length_cm IS NULL
    AND product_height_cm IS NULL
    AND product_width_cm IS NULL;


-- 6. Volume Calculation
-- Creating a derived package volume metric to help identify bulky products

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.products_cleaned` AS
SELECT
    * EXCEPT(product_category_name),
    product_length_cm * product_width_cm * product_height_cm AS volume_cm3
FROM `olist-project-yuliacarvalho.Olist_datasets.products_merged`;


-- 7. Advanced Feature Engineering: Size Flagging
-- Classifying products by dimensional extremity using 75th and 95th percentile thresholds

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.products_final` AS

WITH quantiles AS (
    SELECT
        APPROX_QUANTILES(product_length_cm, 100)[OFFSET(75)] AS p75_len,
        APPROX_QUANTILES(product_length_cm, 100)[OFFSET(95)] AS p95_len,
        APPROX_QUANTILES(product_height_cm, 100)[OFFSET(75)] AS p75_hgt,
        APPROX_QUANTILES(product_height_cm, 100)[OFFSET(95)] AS p95_hgt,
        APPROX_QUANTILES(product_width_cm, 100)[OFFSET(75)] AS p75_wid,
        APPROX_QUANTILES(product_width_cm, 100)[OFFSET(95)] AS p95_wid
    FROM `olist-project-yuliacarvalho.Olist_datasets.products_cleaned`
),

scored AS (
    SELECT
        p.*,

        (
            CASE WHEN product_length_cm >= q.p75_len THEN 1 ELSE 0 END +
            CASE WHEN product_height_cm >= q.p75_hgt THEN 1 ELSE 0 END +
            CASE WHEN product_width_cm >= q.p75_wid THEN 1 ELSE 0 END
        ) AS n_75,

        (
            CASE WHEN product_length_cm >= q.p95_len THEN 1 ELSE 0 END +
            CASE WHEN product_height_cm >= q.p95_hgt THEN 1 ELSE 0 END +
            CASE WHEN product_width_cm >= q.p95_wid THEN 1 ELSE 0 END
        ) AS n_95

    FROM `olist-project-yuliacarvalho.Olist_datasets.products_cleaned` AS p
    CROSS JOIN quantiles AS q
)

SELECT
    * EXCEPT(n_75, n_95),

    CASE
        WHEN n_95 = 3 THEN 6
        WHEN n_95 = 2 THEN 5
        WHEN n_95 = 1 THEN 4
        WHEN n_75 = 3 THEN 3
        WHEN n_75 = 2 THEN 2
        WHEN n_75 = 1 THEN 1
        ELSE 0
    END AS size_flag

FROM scored;


-- 8. Final Product Category Distribution
-- Summary of products per category to identify the largest catalogue segments

SELECT
    product_category_eng,
    COUNT(*) AS n_products
FROM `olist-project-yuliacarvalho.Olist_datasets.products_final`
GROUP BY product_category_eng
ORDER BY n_products DESC;