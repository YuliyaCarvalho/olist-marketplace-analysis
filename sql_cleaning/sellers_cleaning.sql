-- OLIST DATA CLEANING & EDA
-- Table: sellers

-- 1. Primary Key Validation
-- Verifying that seller_id is unique and contains no NULL values

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_ids,
    COUNTIF(seller_id IS NULL) AS null_seller_ids
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers`;


-- 2. Duplicate Row Detection
-- Checking for records where every column value is identical

SELECT
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state,
    COUNT(*) AS cnt
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers`
GROUP BY
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
HAVING COUNT(*) > 1;


-- 3. Initial Cleaning: Whitespace & Specific Typos
-- Removing “df” from city fields and normalising known ingestion artefacts

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.sellers_int_v2` AS
SELECT
    seller_id,

    REPLACE(
        seller_city,
        'aguas claras df',
        'aguas claras'
    ) AS seller_city,

    seller_state,
    seller_zip_prefix

FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_int`;


-- 4. Bulk Standardisation: City Typos and State Corrections
-- Fixing municipal typos and correcting state assignments
-- based on verified city-to-state relationships

UPDATE `olist-project-yuliacarvalho.Olist_datasets.sellers_int_v2`
SET
    seller_city = CASE
        WHEN seller_city = 'ferraz de  vasconcelos' THEN 'ferraz de vasconcelos'
        WHEN seller_city = 'robeirao preto' THEN 'ribeirao preto'
        ELSE seller_city
    END,

    seller_state = CASE
        WHEN seller_city = 'aguas claras' THEN 'DF'
        WHEN seller_city = 'andradas' THEN 'MG'
        WHEN seller_city = 'belo horizonte' THEN 'MG'
        WHEN seller_city = 'blumenau' THEN 'SC'
        WHEN seller_city = 'caxias do sul' THEN 'RS'
        WHEN seller_city = 'chapeco' THEN 'SC'
        WHEN seller_city = 'curitiba' THEN 'PR'
        WHEN seller_city = 'florianopolis' THEN 'SC'
        WHEN seller_city = 'goioere' THEN 'PR'
        WHEN seller_city = 'ipira' THEN 'BA'
        WHEN seller_city = 'itajai' THEN 'SC'
        WHEN seller_city = 'juiz de fora' THEN 'MG'
        WHEN seller_city = 'laguna' THEN 'SC'
        WHEN seller_city = 'laranjeiras do sul' THEN 'PR'
        WHEN seller_city = 'londrina' THEN 'PR'
        WHEN seller_city = 'marechal candido rondon' THEN 'PR'
        WHEN seller_city = 'palhoca' THEN 'SC'
        WHEN seller_city = 'pinhais' THEN 'PR'
        WHEN seller_city = 'porto alegre' THEN 'RS'
        WHEN seller_city = 'rio de janeiro' THEN 'RJ'
        WHEN seller_city = 'sao jose dos pinhais' THEN 'PR'
        WHEN seller_city = 'tocantins' THEN 'MG'
        WHEN seller_city = 'vila velha' THEN 'ES'
        WHEN seller_city = 'volta redonda' THEN 'RJ'
        ELSE seller_state
    END

WHERE seller_city IN (
    'ferraz de  vasconcelos',
    'robeirao preto',
    'aguas claras',
    'andradas',
    'belo horizonte',
    'blumenau',
    'caxias do sul',
    'chapeco',
    'curitiba',
    'florianopolis',
    'goioere',
    'ipira',
    'itajai',
    'juiz de fora',
    'laguna',
    'laranjeiras do sul',
    'londrina',
    'marechal candido rondon',
    'palhoca',
    'pinhais',
    'porto alegre',
    'rio de janeiro',
    'sao jose dos pinhais',
    'tocantins',
    'vila velha',
    'volta redonda'
);


-- 5. Mapping to Customer Dictionary
-- Attempting geographic standardisation by matching seller ZIP prefixes
-- with the previously constructed customer location dictionary

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v2` AS
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    s.seller_zip_prefix,

    d.key AS mapped_key,
    d.state AS mapped_state,
    d.city AS mapped_city,
    d.zip_prefix AS mapped_zip_prefix

FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_int_v2` AS s

LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.customers_dictionary` AS d
    ON s.seller_zip_prefix = d.zip_prefix;


-- 6. Mapping Audit: Identifying Ambiguous ZIP Prefixes
-- Detecting cases where a single ZIP prefix maps to multiple municipalities

SELECT DISTINCT
    zip_prefix
FROM `olist-project-yuliacarvalho.Olist_datasets.customers_dictionary`
QUALIFY COUNT(*) OVER (PARTITION BY zip_prefix) > 1
ORDER BY zip_prefix;


-- 7. Resolving Mapping Ambiguity
-- Removing duplicate rows introduced by ambiguous ZIP matches
-- while preserving rows where city matches the mapped dictionary city

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v2_1` AS

SELECT *
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v2`
WHERE seller_id NOT IN ('4aba391bc3b88717ce08eb11e44937b2', '2493dc3f20131696a0ecdb9948051a8d', -- additional IDs omitted for brevity)
UNION ALL
SELECT *
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v2`
WHERE seller_id IN ('4aba391bc3b88717ce08eb11e44937b2', -- additional IDs omitted for brevity)
AND seller_city = mapped_city;


-- 8. Final External Mapping for Remaining Gaps
-- Using an external “CEPs do Brasil” dataset to resolve sellers
-- not matched by the customer-derived dictionary

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v3_2` AS
SELECT
    sm.seller_id,
    sm.seller_city,
    sm.seller_state,
    sm.seller_zip_prefix,
    b.key AS mapped_key,
    b.state AS mapped_state,
    b.city AS mapped_city,
    sm.seller_zip_prefix AS mapped_zip_prefix
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v2_1` AS sm
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.brazilian_city_zips` AS b
    ON sm.seller_zip_prefix BETWEEN b.cep_range_start AND b.cep_range_end
WHERE sm.mapped_city IS NULL;


-- 9. Final Table Construction
-- Combining dictionary-mapped and externally mapped sellers

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_final` AS
SELECT *
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v3_1`
UNION ALL
SELECT *
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_v3_2`;


-- 10. Final Data Quality Validation
-- Ensuring zero NULL keys and complete geographic mapping

SELECT
    COUNTIF(seller_id IS NULL) AS id_nulls,
    COUNTIF(mapped_key IS NULL) AS key_nulls
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_mapped_final`;


-- 11. Geographic Distribution Summary
-- Overview of seller concentration across Brazilian states

SELECT
    seller_state,
    COUNT(DISTINCT seller_city) AS unique_city_count,
    COUNT(*) AS seller_count,

    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS seller_percentage
FROM `olist-project-yuliacarvalho.Olist_datasets.sellers_final`
GROUP BY seller_state
ORDER BY seller_count DESC;