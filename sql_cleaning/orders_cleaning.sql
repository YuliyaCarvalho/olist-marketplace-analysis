-- ======================================
-- OLIST DATA CLEANING & EDA
-- Table: orders
-- ======================================

-- 1. Primary Key Validation
-- Verifying uniqueness of order_id and checking for NULLs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_order_ids,
    COUNTIF(order_id IS NULL) AS null_order_ids
FROM orders;

-- 2. General Table Summary
-- Generating a high-level overview of order statuses, volume, and date coverage
SELECT
    'Total Orders' AS metric_name,
    CAST(COUNT(DISTINCT order_id) AS STRING) AS value
FROM orders

UNION ALL

SELECT
    'Unique Customers',
    CAST(COUNT(DISTINCT customer_id) AS STRING)
FROM orders

UNION ALL

SELECT
    'Total Records',
    CAST(COUNT(*) AS STRING)
FROM orders

UNION ALL

SELECT
    'Distinct Statuses',
    CAST(COUNT(DISTINCT order_status) AS STRING)
FROM orders

UNION ALL

SELECT
    'Approved Orders',
    CAST(COUNTIF(order_status = 'approved') AS STRING)
FROM orders

UNION ALL

SELECT
    'Cancelled Orders',
    CAST(COUNTIF(order_status = 'canceled') AS STRING)
FROM orders

UNION ALL

SELECT
    'Created Orders',
    CAST(COUNTIF(order_status = 'created') AS STRING)
FROM orders

UNION ALL

SELECT
    'Delivered Orders',
    CAST(COUNTIF(order_status = 'delivered') AS STRING)
FROM orders

UNION ALL

SELECT
    'Invoiced Orders',
    CAST(COUNTIF(order_status = 'invoiced') AS STRING)
FROM orders

UNION ALL

SELECT
    'Shipped Orders',
    CAST(COUNTIF(order_status = 'shipped') AS STRING)
FROM orders

UNION ALL

SELECT
    'Processing Orders',
    CAST(COUNTIF(order_status = 'processing') AS STRING)
FROM orders

UNION ALL

SELECT
    'Unavailable Orders',
    CAST(COUNTIF(order_status = 'unavailable') AS STRING)
FROM orders

UNION ALL

SELECT
    'Earliest Order Date',
    CAST(MIN(order_purchase_timestamp) AS STRING)
FROM orders

UNION ALL

SELECT
    'Latest Order Date',
    CAST(MAX(order_purchase_timestamp) AS STRING)
FROM orders

ORDER BY value DESC;

-- 3. Order Status Distribution
-- Inspecting the share of each lifecycle stage to prioritize delivered orders
SELECT
    order_status,
    COUNT(*) AS nb_orders_per_status,
    ROUND(COUNT(*) * 100 / (SELECT COUNT(*) FROM orders), 2) AS percent_orders_per_status
FROM orders
GROUP BY order_status
ORDER BY nb_orders_per_status DESC;

-- 4. NULL Value Profiling
-- Identifying missing data across all columns to detect logical gaps in fulfillment
SELECT
    COUNT(*) AS total_rows,
    COUNTIF(order_id IS NULL) AS order_id_nulls,
    COUNTIF(customer_id IS NULL) AS customer_id_nulls,
    COUNTIF(order_status IS NULL) AS order_status_nulls,
    COUNTIF(order_purchase_timestamp IS NULL) AS order_purchase_timestamp_nulls,
    COUNTIF(order_approved_at IS NULL) AS order_approved_at_nulls,
    COUNTIF(order_delivered_carrier_date IS NULL) AS order_delivered_carrier_date_nulls,
    COUNTIF(order_delivered_customer_date IS NULL) AS order_delivered_customer_date_nulls,
    COUNTIF(order_estimated_delivery_date IS NULL) AS order_estimated_delivery_date_nulls
FROM orders;

-- 5. Status-Timestamp Consistency Check
-- Flagging orders marked delivered that lack a customer receipt timestamp
SELECT
    order_id,
    order_status,
    order_delivered_carrier_date,
    order_delivered_customer_date
FROM orders
WHERE order_delivered_customer_date IS NULL
  AND order_status = 'delivered';

-- 6. Chronological Violation Audits
-- Identifying physically impossible sequences to validate data pipeline integrity

-- 6a. Approved before purchase?
SELECT COUNT(*) AS approved_before_purchase
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

-- 6b. Dispatched to carrier before payment approval?
SELECT COUNT(*) AS carrier_before_approval
FROM orders
WHERE order_delivered_carrier_date < order_approved_at;

-- 6c. Received by customer before dispatch to carrier?
SELECT COUNT(*) AS customer_before_carrier
FROM orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

-- 7. Delivery Duration Diagnostics
-- Calculating timeframes to spot negative or extreme values before KPI generation
SELECT
    COUNT(*) AS rows_with_both_dates,
    MIN(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY)) AS min_days,
    MAX(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY)) AS max_days,
    ROUND(AVG(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY)), 1) AS avg_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL;

-- 8. Table Enrichment: Initial Flags & Derived Metrics
-- Creating a robust analytical table with quality flags and lag calculations
CREATE OR REPLACE TABLE orders_enriched AS
SELECT
    o.*,

    -- QA flags
    CASE
        WHEN order_approved_at IS NOT NULL THEN 1
        ELSE 0
    END AS has_approval,

    CASE
        WHEN order_delivered_customer_date IS NOT NULL THEN 1
        ELSE 0
    END AS delivery_timestamp_is_complete,

    CASE
        WHEN order_delivered_carrier_date < order_approved_at THEN 1
        ELSE 0
    END AS carrier_before_approval,

    CASE
        WHEN order_delivered_carrier_date < order_purchase_timestamp THEN 1
        ELSE 0
    END AS carrier_before_purchase,

    CASE
        WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1
        ELSE 0
    END AS customer_before_carrier,

    -- Timing metrics
    DATE_DIFF(
        DATE(order_delivered_customer_date),
        DATE(order_purchase_timestamp),
        DAY
    ) AS order_to_delivery_days,

    ROUND(
        TIMESTAMP_DIFF(order_approved_at, order_purchase_timestamp, MINUTE) / 60.0,
        1
    ) AS approval_lag_hours,

    -- Chronology validity
    CASE
        WHEN order_purchase_timestamp <= order_approved_at
         AND order_approved_at <= order_delivered_carrier_date
         AND order_delivered_carrier_date <= order_delivered_customer_date
        THEN 1
        ELSE 0
    END AS timeline_is_valid

FROM orders AS o;

-- 9. Derived Dataset: Delivered Orders Only
-- Isolating high-quality completed orders for logistics performance modeling
CREATE OR REPLACE TABLE delivered_orders AS
SELECT *
FROM orders_enriched
WHERE order_status = 'delivered'
  AND delivery_timestamp_is_complete = 1;

-- 10. Identification of Hanging Orders
-- Sequentially flagging orders stuck in intermediate stages beyond category-level max transit times

-- 10a. Define dataset horizon (latest event)
SELECT
    GREATEST(
        MAX(order_purchase_timestamp),
        MAX(order_approved_at),
        MAX(order_delivered_carrier_date),
        MAX(order_delivered_customer_date)
    ) AS dataset_horizon
FROM orders_enriched;

-- 10b. Consolidating all intermediate hanging flags
CREATE OR REPLACE TABLE orders_final AS
SELECT
    *,
    CASE
        WHEN order_status IN ('delivered', 'canceled', 'unavailable') THEN 0
        WHEN order_status = 'created' THEN 1
        ELSE GREATEST(
            COALESCE(is_hanging_shipped, 0),
            COALESCE(is_hanging_approved, 0),
            COALESCE(is_hanging_invoiced, 0),
            COALESCE(is_hanging_processing, 0)
        )
    END AS is_hanging
FROM orders_enriched_v6;

-- 11. Final Summary of Stuck Orders
-- Quantifying the operational bottleneck
SELECT
    is_hanging,
    COUNT(*) AS num_orders,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_orders
FROM orders_final
GROUP BY is_hanging
ORDER BY is_hanging DESC;