-- OLIST DATA CLEANING & EDA
-- Table: order_review

-- 1. Initial Cleaning and Standardisation
-- Trimming whitespace, converting numeric scores to descriptive labels, and calculating the response lag between review creation and answer

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_review` AS
SELECT
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,

    CASE
        WHEN review_score = 5 THEN 'excellent'
        WHEN review_score = 4 THEN 'good'
        WHEN review_score = 3 THEN 'neutral'
        WHEN review_score = 2 THEN 'bad'
        WHEN review_score = 1 THEN 'very bad'
        ELSE 'unknown'
    END AS review_score,

    TRIM(review_comment_title) AS review_comment_title,
    TRIM(review_comment_message) AS review_comment_message,

    DATE(review_creation_date) AS review_creation_date,
    review_answer_timestamp,

    DATE_DIFF(DATE(review_answer_timestamp), DATE(review_creation_date), DAY) AS review_to_answer

FROM `olist-project-yuliacarvalho.Olist_datasets.order_review`;


-- 2. NULL Value Profiling
-- Auditing completeness across user-input fields and system timestamps

SELECT
    COUNT(*) AS total_rows,
    COUNTIF(review_id IS NULL) AS review_id_nulls,
    COUNTIF(order_id IS NULL) AS order_id_nulls,
    COUNTIF(review_score IS NULL) AS review_score_nulls,
    COUNTIF(review_comment_title IS NULL) AS review_comment_title_nulls,
    COUNTIF(review_comment_message IS NULL) AS review_comment_message_nulls,
    COUNTIF(review_creation_date IS NULL) AS review_creation_date_nulls,
    COUNTIF(review_answer_timestamp IS NULL) AS review_answer_timestamp_nulls
FROM `olist-project-yuliacarvalho.Olist_datasets.order_review`;


-- 3. Referential Integrity Check
-- Ensuring every review references an existing order

SELECT
    COUNT(DISTINCT r.order_id) AS distinct_review_orders,
    COUNTIF(o.order_id IS NULL) AS missing_in_orders
FROM `olist-project-yuliacarvalho.Olist_datasets.order_review` AS r
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
    ON r.order_id = o.order_id;


-- 4. Duplication Analysis: Multiple Reviews per Order
-- Identifying orders with more than one submitted review

SELECT
    order_id,
    COUNT(*) AS num_reviews
FROM `olist-project-yuliacarvalho.Olist_datasets.order_review`
GROUP BY order_id
HAVING num_reviews > 1
ORDER BY num_reviews DESC;


-- 5. Deduplication: Keeping the Latest Attempt
-- Retaining only the most recent review per order

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_review_deduped` AS

WITH latest_reviews AS (

    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_creation_date DESC) AS row_num

    FROM `olist-project-yuliacarvalho.Olist_datasets.order_review`

)

SELECT
    * EXCEPT(row_num)
FROM latest_reviews
WHERE row_num = 1;


-- 6. Temporal Enrichment & Validation
-- Joining with orders to detect temporal anomalies: "IMPOSSIBLE" reviews (before purchase) and "SUSPECT" reviews (>90 days after purchase)

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_review_enriched` AS
SELECT
    r.*,
    o.order_purchase_timestamp,
    o.order_status,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,

    CASE
        WHEN r.review_creation_date < DATE(o.order_purchase_timestamp)
            THEN 'IMPOSSIBLE'

        WHEN r.review_creation_date >
            DATE_ADD(DATE(o.order_purchase_timestamp), INTERVAL 90 DAY)
            THEN 'SUSPECT'

        ELSE 'VALID'
    END AS temporal_flag

FROM `olist-project-yuliacarvalho.Olist_datasets.order_review_deduped` AS r

LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
USING(order_id);


-- 7. Systematic Data Corruption Audit
-- Detecting repeated reviews mapped to different orders within identical timestamps

SELECT
    review_score,
    review_comment_message,
    review_creation_date,
    COUNT(DISTINCT order_id) AS total_distinct_orders

FROM `olist-project-yuliacarvalho.Olist_datasets.order_review_enriched`

WHERE review_comment_message IS NOT NULL

GROUP BY
    review_score,
    review_comment_message,
    review_creation_date

HAVING total_distinct_orders > 1
ORDER BY total_distinct_orders DESC;


-- 8. Final Clean Table Creation
-- Removing corrupted review IDs and temporal anomalies to produce an analysis-ready dataset

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_review_final` AS
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    review_to_answer

FROM `olist-project-yuliacarvalho.Olist_datasets.order_review_enriched`

WHERE temporal_flag = 'VALID'

AND review_id NOT IN (

    SELECT review_id
    FROM (
        SELECT
            review_id,
            COUNT(order_id) OVER (PARTITION BY review_id) AS cnt
        FROM `olist-project-yuliacarvalho.Olist_datasets.order_review`
    )
    WHERE cnt > 1);


-- 9. Final Coverage Check
-- Calculating the proportion of orders that received a valid review

SELECT
    CASE
        WHEN r.order_id IS NULL THEN 'No Review'
        ELSE 'Has Review'
    END AS review_status,

    COUNT(*) AS order_count,

    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_coverage

FROM `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.order_review_final` AS r ON o.order_id = r.order_id
GROUP BY review_status;