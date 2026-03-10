
-- OLIST DATA CLEANING & EDA
-- Table: geolocation

-- 1. Table Size and Primary Key Context
-- Verifying the scale of the dataset. This is the largest table in the dataset. The implicit primary key is a combination of all columns, as multiple coordinates can exist for a single ZIP prefix.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT geolocation_zip_code_prefix) AS unique_zip_prefixes
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation`;


-- 2. Detection of Global Outliers (Non-Brazilian Coordinates)
-- Identifying coordinates that fall outside Brazil’s bounding box - Brazilian bounding box (approx.): Latitude [-34, 5], Longitude [-74, -34]

SELECT
    *
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation`
WHERE geolocation_lat > 5
    OR geolocation_lat < -34
    OR geolocation_lng > -34
    OR geolocation_lng < -74
LIMIT 20;


-- 3. Investigating Municipal Inconsistencies
-- Detecting ZIP prefixes associated with multiple city name variants

SELECT
    geolocation_zip_code_prefix,
    COUNT(DISTINCT geolocation_city) AS city_variant_count,
    ARRAY_AGG(DISTINCT geolocation_city) AS city_variants
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation`
GROUP BY geolocation_zip_code_prefix
HAVING city_variant_count > 1
ORDER BY city_variant_count DESC;


-- 4. Cleaning and Standardisation via Brazilian CEP Reference
-- Using the external "brazilian_city_zips" reference dataset (derived from "Lista_de_CEPs.xlsx") to standardise city and state names

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.geolocation_ready` AS
SELECT
    g.*,
    c.state AS official_state,
    c.city AS official_city,
    c.key AS geo_key
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation_cleaned` AS g
LEFT JOIN `olist-project-yuliacarvalho.Olist_datasets.brazilian_city_zips` AS c
    ON g.geolocation_zip_code_prefix
       BETWEEN c.cep_range_start AND c.cep_range_end;


-- 5. Final Table Construction: geolocation_final
-- Creating the analysis-ready table and ensuring all coordinates fall within Brazil’s geographic boundaries

CREATE OR REPLACE TABLE `olist-project-yuliacarvalho.Olist_datasets.geolocation_final` AS
SELECT
    geolocation_zip_code_prefix AS zip_prefix,
    geolocation_lat,
    geolocation_lng,
    official_city AS city,
    official_state AS state
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation_ready`
WHERE geolocation_lat BETWEEN -34 AND 5 AND geolocation_lng BETWEEN -74 AND -34;


-- 6. Quality Audit: Final Coverage
-- Checking how many rows were retained after filtering and mapping

SELECT
    COUNT(*) AS final_row_count,
    ROUND(COUNT(*) / 714971 * 100, 2) AS pct_retention
FROM `olist-project-yuliacarvalho.Olist_datasets.geolocation_final`;