This document explains how to reproduce the analytical workflow used in the Olist marketplace analysis project.

# Reproducing the Analysis

This project was developed using a **Kaggle R Notebook connected to Google BigQuery**.

The workflow follows a **warehouse-first analytical approach**, where SQL transformations are executed in BigQuery before analytical queries and visualizations are performed in the notebook.

---

## Environment

Platform: [Kaggle Notebooks](https://www.kaggle.com/docs/notebooks#the-notebooks-environment)  
Language: R  
Data Warehouse: Google BigQuery  

The notebook was executed in a **pinned Kaggle runtime environment (2024-07-11)** to ensure stable package versions and prevent future platform updates from breaking the analysis.

Runtime details:

- R version: 4.4.0  
- Operating system: Ubuntu 22.04  
- Notebook runtime: Kaggle container environment  
- BigQuery interface: `bigrquery` R package  

The Kaggle notebook runs in a **non-persistent environment**, meaning each execution starts from a clean container.  
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
# Reproducing the Analysis

This project was developed using a **Kaggle R Notebook connected to Google BigQuery**.

The workflow follows a **warehouse-first analytical approach**, where SQL transformations are executed in BigQuery before analytical queries and visualizations are performed in the notebook.

---

## Environment

Platform: [Kaggle Notebooks](https://www.kaggle.com/docs/notebooks#the-notebooks-environment)  
Language: R  
Data Warehouse: Google BigQuery  

The notebook was executed in a **pinned Kaggle runtime environment (2024-07-11)** to ensure stable package versions and prevent future platform updates from breaking the analysis.

Runtime details:

- R version: 4.4.0  
- Operating system: Ubuntu 22.04  
- Notebook runtime: Kaggle container environment  
- BigQuery interface: `bigrquery` R package  

The Kaggle notebook runs in a **non-persistent environment**, meaning each execution starts from a clean container.  
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
---
run_small_query("
SELECT order_status, COUNT(*)
FROM orders
GROUP BY order_status
")
---


---

### 2. Transformational Queries

When inconsistencies were discovered during exploratory analysis, corrective transformations were applied directly in BigQuery.

These transformations typically used statements such as:
---
CREATE OR REPLACE TABLE dataset.table_name AS
SELECT ...
---


These queries were used to:

- clean timestamp fields
- generate validation flags
- derive delivery metrics
- create analytical fact tables

Examples of derived tables created during the analysis include:

- `orders_final`
- `order_items_final`
- `payments_final`
- `products_final`
- `delivered_orders_items_final`

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

To reproduce the analysis:

1. Open the [Kaggle notebook](https://www.kaggle.com/code/yuliyacarvalho/olist-retention-logistics-risk).
2. Connect the notebook to your Google BigQuery account.
3. Run the notebook **from top to bottom**.

Because the workflow is exploratory, some cleaning queries appear interspersed with exploratory queries.

However, executing the notebook sequentially will rebuild the final analytical tables used in the analysis.

---

## Important Notes

The transformation queries create tables using `CREATE OR REPLACE`.

Running the notebook multiple times will **overwrite existing derived tables** in the dataset.

This ensures the analysis always runs on the most recent transformation logic.

Because the notebook environment is non-persistent, all important data transformations are stored in BigQuery rather than in the notebook filesystem.

---

## Helper Functions

Several helper functions were created to simplify query execution and result inspection.

Documentation:

`docs/helper_functions.md` ➡ [Helper functions documentation LINK](../docs/helper_functions.md)

These functions standardize how SQL queries are executed and how results are displayed within the notebook.

---

## BigQuery Connection

Details about the BigQuery connection setup are documented here:

`reproducibility/bigquery_connection.md` ➡ [BigQuery connection setup LINK](bigquery_connection.md)