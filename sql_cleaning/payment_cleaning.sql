-- OLIST DATA CLEANING & EDA
-- Table: order_payments


-- 1. Initial Cleaning: Whitespace Trimming and Normalisation
-- Removing leading/trailing spaces and converting IDs and payment types to lowercase for consistency

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_payments` AS
SELECT
    LOWER(TRIM(order_id)) AS order_id,
    payment_sequential,
    LOWER(TRIM(payment_type)) AS payment_type,
    payment_installments,
    payment_value
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`;


-- 2. Primary Key Validation
-- Verifying that the combination of order_id and payment_sequential is unique

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS count
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
GROUP BY
    order_id,
    payment_sequential
HAVING count > 1;


-- 3. NULL Value Profiling
-- Auditing all columns to ensure no missing data was introduced during ingestion

SELECT
    COUNTIF(order_id IS NULL) AS order_id_nulls,
    COUNTIF(payment_sequential IS NULL) AS payment_seq_nulls,
    COUNTIF(payment_type IS NULL) AS payment_type_nulls,
    COUNTIF(payment_installments IS NULL) AS payment_installments_nulls,
    COUNTIF(payment_value IS NULL) AS payment_value_nulls
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`;


-- 4. Payment Method Distribution
-- Understanding the prevalence of different payment types across the platform

SELECT
    payment_type,
    COUNT(*) AS orders_per_payment_type,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 3) AS pct_orders
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
GROUP BY payment_type;


-- 5. Referential Integrity: Cross-check with Orders
-- Identifying payments that do not map to a corresponding parent order

SELECT
    COUNT(DISTINCT p.order_id) AS payment_orders,
    COUNT(DISTINCT o.order_id) AS matched_orders,
    COUNT(DISTINCT p.order_id) - COUNT(DISTINCT o.order_id) AS missing_order_ids
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments` AS p
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.orders_final` AS o
USING(order_id);


-- 6. Identifying Orders Without Payment Records
-- Finding orders that completed the lifecycle but lack payment data

SELECT
    o.*
FROM `olist-project-yuliacarvalho.Olist_datasets.orders_final` AS o
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.order_payments` AS p
USING(order_id)
WHERE p.order_id IS NULL;


-- 7. Flagging Payment Completeness in Orders Table
-- Marking orders that lack a payment record for later exclusion from monetary KPIs

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.orders_final` AS
SELECT
    o.*,
    CASE
        WHEN p.order_id IS NOT NULL THEN 1
        ELSE 0
    END AS has_payment_record

FROM `olist-project-yuliacarvalho.Olist_datasets.orders_final` AS o
LEFT JOIN (
    SELECT DISTINCT
        order_id
    FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`) AS p
USING(order_id);


-- 8. Split Payment Analysis
-- Calculating how many orders were paid using multiple payment entries

SELECT
    COUNTIF(payment_count > 1) AS multi_payment_orders,
    COUNT(*) AS total_orders,

    ROUND(100 * COUNTIF(payment_count > 1) / COUNT(*), 2) AS pct_multi_payment_ord

FROM (
    SELECT
        order_id,
        COUNT(*) AS payment_count
    FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
    GROUP BY order_id
);


-- 9. Payment Installment Distribution
-- Auditing the installment structure of marketplace payments

SELECT
    payment_installments,
    COUNT(*) AS num_payments,
    COUNT(DISTINCT order_id) AS num_orders
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
GROUP BY payment_installments
ORDER BY payment_installments;


-- 10. Outlier Detection: Zero-Installment Orders
-- Identifying rare cases where installments were recorded as zero

SELECT
    *
FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
WHERE payment_installments = 0;


-- 11. Value Analysis: Micro and Zero Payments
-- Flagging transactions below 1 BRL and exactly 0 BRL to protect GMV calculations

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.order_payments_final` AS
SELECT
    *,
    CASE
        WHEN payment_value > 0 AND payment_value < 1 THEN 1
        ELSE 0
    END AS is_micro_payment,

    CASE
        WHEN payment_value = 0 THEN 1
        ELSE 0
    END AS is_zero_payment

FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`;


-- 12. Payment-Item Consistency Validation
-- Comparing order-level payment totals against item price plus freight totals

WITH order_level AS (

    SELECT
        o.order_id,
        o.order_status,
        IFNULL(p.total_payment_value, 0) AS total_payment_value,
        IFNULL(i.total_item_value, 0) AS total_item_value,

        ROUND(
            IFNULL(p.total_payment_value, 0) - IFNULL(i.total_item_value, 0), 2) AS payment_minus_items

    FROM `olist-project-yuliacarvalho.Olist_datasets.orders` AS o
    LEFT JOIN (
        SELECT
            order_id,
            SUM(payment_value) AS total_payment_value
        FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
        GROUP BY order_id) AS p
    USING(order_id)

    LEFT JOIN (
        SELECT
            order_id,
            SUM(price + freight_value) AS total_item_value
        FROM `olist-project-yuliacarvalho.Olist_datasets.order_items_final`
        GROUP BY order_id
    ) AS i
    USING(order_id)
)

SELECT
    order_status,
    COUNT(*) AS num_orders,
    SUM(
        CASE
            WHEN total_payment_value = 0 THEN 1
            ELSE 0
        END
    ) AS orders_with_zero_payment,
    SUM(
        CASE
            WHEN ABS(payment_minus_items) > 1 THEN 1
            ELSE 0
        END
    ) AS orders_with_gaps
FROM order_level
GROUP BY order_status;


-- 13. Edge Case Diagnostic: Shipped Order with Zero Item Value
-- Investigating shipped orders where payment exists but item-level value is missing

SELECT
    *
FROM (
    SELECT
        o.order_id,
        o.order_status,
        IFNULL(p.total_payment_value, 0) AS total_payment_value,
        IFNULL(i.total_item_value, 0) AS total_item_value

    FROM `olist-project-yuliacarvalho.Olist_datasets.orders_final` AS o

    LEFT JOIN (
        SELECT
            order_id,
            SUM(payment_value) AS total_payment_value
        FROM `olist-project-yuliacarvalho.Olist_datasets.order_payments`
        GROUP BY order_id) AS p
    USING(order_id)

    LEFT JOIN (
        SELECT
            order_id,
            SUM(price + freight_value) AS total_item_value
        FROM `olist-project-yuliacarvalho.Olist_datasets.order_items_final`
        GROUP BY order_id) AS i
    USING(order_id))
WHERE order_status = 'shipped'
    AND total_item_value = 0;