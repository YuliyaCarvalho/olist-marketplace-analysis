> [!IMPORTANT]
> This document explains how to reproduce the analytical workflow used in the Olist marketplace analysis project.

# Reproducing the Analysis

This project was developed using a **Kaggle R Notebook connected to Google BigQuery**.

The workflow follows a **warehouse-first analytical approach**, where SQL transformations are executed in BigQuery before analytical queries and visualizations are performed in the notebook.

---

## Environment

Platform: [Kaggle Notebooks](https://www.kaggle.com/docs/notebooks#the-notebooks-environment)  
Language: R  
Data Warehouse: Google BigQuery  

The notebook was executed in a **pinned Kaggle runtime environment (2024-07-11)** to ensure stable package versions and prevent future platform updates from breaking the analysis.


### Runtime Details

- **R version:** 4.4.0  
- **Operating system:** Ubuntu 22.04  
- **Notebook runtime:** Kaggle container environment  
- **BigQuery interface:** `bigrquery` R package

The Kaggle notebook runs in a **non-persistent container environment**, meaning each execution starts from a clean container.  
No files are stored locally between runs, and all analytical datasets are stored in Google BigQuery.

Core libraries used:

- bigrquery
- DBI
- dplyr
- tidyr  
- skimr  
- knitr  
- ggplot2
- lubridate

---

## Data Source

Dataset: **Olist Brazilian E-Commerce Public Dataset**

The raw [dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) was imported into a personal Google BigQuery project and stored as native tables.

The analysis builds several **derived tables** inside BigQuery to clean and enrich the dataset.

---

## Analysis Workflow

The analysis followed an **iterative exploratory workflow** rather than a strictly linear ETL pipeline.

SQL queries were executed from the Kaggle notebook using the BigQuery connection, and two types of queries were interwoven during the analysis.

---

### 1. Exploratory Queries (EDA)

During the early stages of the project, SQL queries were executed to explore the dataset and identify potential inconsistencies.

Examples of exploratory checks included:

- validating delivery timelines
- inspecting missing timestamps
- identifying anomalous payment values
- examining delivery delay distributions

These queries typically used `SELECT` statements executed through helper functions in the notebook.

Example:

```r
run_small_query("
SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status
")
```

### 2. Transformational Queries

When inconsistencies were discovered during exploratory analysis, corrective transformations were applied directly in BigQuery.

These transformations typically used statements such as:

```sql
CREATE OR REPLACE TABLE dataset.table_name AS
SELECT ...
```

These queries were used to:

- clean timestamp fields
- generate validation flags
- derive delivery metrics
- create analytical fact tables

Examples of derived tables created during the analysis include:

- `tablename_clean`
- `tablename_intermediate`
- `tablename_final`

Because these transformations overwrite previous versions of the tables, running the notebook again will recreate the cleaned tables.

---

### 3. Analytical Queries

Once the cleaned tables were available, analytical SQL queries were executed to generate the metrics used in the project.

These queries produced datasets used for:

- visualizations
- statistical summaries
- operational insights
- business recommendations

---

## Execution Order

There are two ways to explore or reproduce this analysis.

---

### Option 1 — Explore the Analysis (Recommended)

The easiest way to review the full analysis is through the published Kaggle notebook: [Olist: Retention, Logistics & Risk](https://www.kaggle.com/code/yuliyacarvalho/olist-retention-logistics-risk)

The notebook contains the complete analytical workflow, including:

- exploratory queries
- derived datasets
- statistical analysis
- visualisations
- business insights

Because the notebook was executed before publication, all results and figures are already rendered and can be inspected directly without running the code.

---

### Option 2 — Rebuild the Analytical Dataset

To fully reproduce the data transformations locally:

1. Download the [**Olist Brazilian E-Commerce Dataset**]( https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
 
2. Import the raw tables into your own **Google BigQuery project**.

3. Execute the [SQL scripts](../sql_cleaning/) provided in the repository. Each SQL file contains the validation checks and transformation logic used to construct the cleaned analytical tables. Before executing the scripts, replace the project and dataset identifiers (e.g. `olist-project-yuliacarvalho.Olist_datasets`) with the corresponding names in your own BigQuery environment.

4. Once the cleaned tables are created, you can run the R code contained in the Kaggle notebook.

---

> [!IMPORTANT]
> * The original analysis was performed using a **warehouse-first workflow**:
```
Raw Olist dataset
        ↓
BigQuery cleaning & feature engineering
        ↓
Derived analytical tables
        ↓
R analysis and visualization in Kaggle
```

* Because the notebook was designed for **exploratory analysis**, SQL queries for validation, cleaning, and transformation appear interspersed throughout the workflow.
* However, the SQL scripts in the `/sql_cleaning` directory contain the finalized transformation logic used to build the analytical dataset.
* Because the notebook environment is non-persistent, all important data transformations are stored in BigQuery rather than in the notebook filesystem.

---

## Helper Functions

Several helper functions were created to simplify query execution and result inspection.

Documentation:

`docs/helper_functions.md` ➡ [Helper functions documentation](../docs/helper_functions.md)

These functions standardize how SQL queries are executed and how results are displayed within the notebook.

---

## BigQuery Connection

Details about the BigQuery connection setup are documented here:

`reproducibility/bigquery_connection.md` ➡ [BigQuery connection setup](bigquery_connection.md)

---

## Data Cleaning SQL

All cleaning logic used to construct the analytical tables is documented in the `/sql_cleaning` directory.

Each SQL file corresponds to a raw dataset table and contains validation checks, anomaly detection queries, and transformation logic used during the cleaning and EDA phases.   
