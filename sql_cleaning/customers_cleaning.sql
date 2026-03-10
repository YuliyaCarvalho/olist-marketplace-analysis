-- OLIST DATA CLEANING & EDA
-- Table: customers


-- 1. Initial Cleaning: Whitespace Trimming
-- Standardising STRING columns by removing leading/trailing spaces
-- to prevent JOIN mismatches

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers` AS
SELECT
    TRIM(customer_id) AS customer_id,
    TRIM(customer_unique_id) AS customer_unique_id,
    customer_zip_code_prefix,
    TRIM(customer_city) AS customer_city,
    TRIM(customer_state) AS customer_state
FROM `olist-project-yuliacarvalho.Olist_datasets.customers`;


-- 2. Duplicate Row Detection
-- Identifying records where all column values are identical

SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix,
    COUNT(*) AS cnt
FROM `olist-project-yuliacarvalho.Olist_datasets.customers`
GROUP BY
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix
HAVING COUNT(*) > 1;


-- 3. Primary Key Validation
-- Verifying that customer_id is unique and contains no NULL values

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_ids,
    COUNTIF(customer_id IS NULL) AS null_customer_ids
FROM `olist-project-yuliacarvalho.Olist_datasets.customers`;


-- 4. NULL Value Profiling
-- Checking all remaining columns for missing data

SELECT
    COUNT(*) AS total_rows,
    COUNTIF(customer_unique_id IS NULL) AS customer_unique_id_nulls,
    COUNTIF(customer_zip_code_prefix IS NULL) AS customer_zip_code_prefix_nulls,
    COUNTIF(customer_city IS NULL) AS customer_city_nulls,
    COUNTIF(customer_state IS NULL) AS customer_state_nulls
FROM `olist-project-yuliacarvalho.Olist_datasets.customers`;


-- 5. ZIP Code Standardisation
-- Identifying 4-digit prefixes that lost leading zeros during ingestion

SELECT
    SUM(IF(LENGTH(CAST(customer_zip_code_prefix AS STRING)) = 4, 1, 0)) AS zip_4_digit_count,
    SUM(IF(LENGTH(CAST(customer_zip_code_prefix AS STRING)) = 5, 1, 0)) AS zip_5_digit_count
FROM `olist-project-yuliacarvalho.Olist_datasets.customers`;


-- 5b. Fixing ZIP Codes
-- Converting to STRING and padding with a leading zero where necessary

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers_int` AS
SELECT
    * EXCEPT(customer_zip_code_prefix),

    CASE
        WHEN LENGTH(CAST(customer_zip_code_prefix AS STRING)) = 4
        THEN LPAD(CAST(customer_zip_code_prefix AS STRING), 5, '0')
        ELSE CAST(customer_zip_code_prefix AS STRING)
    END AS customer_zip_prefix

FROM `olist-project-yuliacarvalho.Olist_datasets.customers`;


-- 6. Geographic Distribution Summary
-- High-level overview of customer concentration by state

SELECT
    customer_state,
    COUNT(DISTINCT customer_city) AS unique_city_count,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS customer_percentage
FROM `olist-project-yuliacarvalho.Olist_datasets.customers_int`
GROUP BY customer_state
ORDER BY customer_count DESC;


-- 7. Building a Geographic Reference Dictionary
-- Creating a composite key (State-City) to standardise location data

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers_geo_dict` AS
SELECT
    customer_city AS city,
    customer_state AS state,
    CONCAT(customer_state, '-', customer_city) AS key,
    customer_zip_prefix AS zip_prefix
FROM `olist-project-yuliacarvalho.Olist_datasets.customers_int`;


-- 8. Advanced Standardisation: Typos and Inconsistencies
-- Resolving city name variations to improve JOIN reliability


-- Step 1 & 2: Handling apostrophes and specific suffixes

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers_cleaned_step2` AS
SELECT
    customer_id,
    customer_unique_id,

    REPLACE(
        REPLACE(
            REPLACE(customer_city, 'd oeste', "d'oeste"),
            'do oeste', "d'oeste"
        ),
        'd avila', "d'avila"
    ) AS customer_city,

    customer_state,
    customer_zip_prefix

FROM `olist-project-yuliacarvalho.Olist_datasets.customers_int`;


-- Step 3: Final bulk replacements for identified municipal typos

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers_final` AS
SELECT
    customer_id,
    customer_unique_id,

    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(customer_city, 'embu', 'embu das artes'),
                'mogi-mirim', 'mogi mirim'
            ),
            'parati', 'paraty'
        ),
        'brasopolis', 'brazopolis'
    ) AS customer_city,

    customer_state,
    customer_zip_prefix

FROM `olist-project-yuliacarvalho.Olist_datasets.customers_cleaned_step2`;


-- 9. Final Clean Dictionary Extraction
-- Creating a unique lookup table for State/City/Zip combinations

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.customers_dictionary` AS
SELECT DISTINCT
    state,
    city,
    CONCAT(state, '-', city) AS key,
    zip_prefix
FROM (
    SELECT
        customer_state AS state,
        customer_city AS city,
        customer_zip_prefix AS zip_prefix
    FROM `olist-project-yuliacarvalho.Olist_datasets.customers_final`)
ORDER BY state, city, zip_prefix;


-- 10. Audit: Validating Zip Code Overlaps
-- Confirming ZIP prefixes that legally span multiple municipalities

SELECT
    zip_prefix,
    COUNT(*) AS prefix_count
FROM `olist-project-yuliacarvalho.Olist_datasets.customers_dictionary`
GROUP BY zip_prefix
HAVING prefix_count > 1
ORDER BY zip_prefix;