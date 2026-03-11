# Olist Marketplace Analysis
### Retention, Logistics Performance & Operational Risk

Data-driven analysis of the **Olist Brazilian e-commerce marketplace (2016–2018)** using SQL queries executed in **Google BigQuery** and analyzed in a **Kaggle R notebook**.

The goal of this project is to identify operational bottlenecks and growth opportunities by analyzing:

- marketplace growth (GMV trends)
- logistics performance (delivery delays & route bottlenecks)
- seller risk concentration
- customer retention patterns

---

# Project Snapshot

Data source: [Olist Brazilian E-Commerce Marketplace Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
Time Period: 2016–2018  

The dataset contains information about:

- orders
- order items
- payments
- products
- sellers
- customers
- geographical information
- customer reviews

Orders analyzed: ~100,000  
Customers: ~96,000  
Sellers: ~3,000  

Warehouse: Google BigQuery  
Analysis: Kaggle R Notebook (SQL, R)

Complete Notebook:  
[Olist: Retention, Logistics & Risk](https://www.kaggle.com/code/yuliyacarvalho/olist-retention-logistics-risk)

---

## Dataset Schema (ERD)

The analytical warehouse is built on the Olist marketplace dataset, linking orders, customers, sellers, products, payments and reviews.

![Dataset ERD](docs/dataset_erd.png)

---

# Explore the Project

### Business Analysis

The analysis is structured as a set of focused business questions covering marketplace growth, customer behavior, operations, and profitability.

➡️ **[Browse Business Questions](./business_questions/)**

Examples:

- [GMV Trends](./business_questions/01_marketplace_growth/q01_gmv_trends/)
- [Repeat Customer Share](./business_questions/02_customer_behavior/q06_repeat_customer_share/)
- [Delivery Speed vs Repeat Rate](./business_questions/03_operations_and_logistics/q11_delivery_speed_vs_repeat_rate/)
- [Churn by Review Score](./business_questions/04_profitability_and_risk/q14_churn_by_review_score/)

---

### SQL Data Preparation

All datasets were cleaned, validated, and enriched using **BigQuery SQL**.

➡️ **[View SQL Cleaning Pipeline](./sql_cleaning/)**

Key scripts:

- [customers_cleaning.sql](./sql_cleaning/customers_cleaning.sql)
- [orders_cleaning.sql](./sql_cleaning/orders_cleaning.sql)
- [order_items_cleaning.sql](./sql_cleaning/order_items_cleaning.sql)
- [products_cleaning.sql](./sql_cleaning/products_cleaning.sql)
- [reviews_cleaning.sql](./sql_cleaning/reviews_cleaning.sql)
- [payments_cleaning.sql](./sql_cleaning/payment_cleaning.sql)

---

### Full End-to-End Notebook

The entire investigation is also available as a single continuous notebook.

- 📓 [Jupyter Notebook](./notebooks/olist-retention-logistics-risk.ipynb)
- 🌐 [HTML Version](./notebooks/olist-retention-logistics-risk.html)
- 📄 [PDF Version](./notebooks/olist-retention-logistics-risk.pdf)
- [Markdown Version](./notebooks/olist-retention-logistics-risk.md)

or you can check out the original  
[Kaggle Notebook](https://www.kaggle.com/code/yuliyacarvalho/olist-retention-logistics-risk)

---

# Key Findings

➜ **Delivery delays are the primary driver of dissatisfaction**  
Crossing the 3-day delay threshold increases negative reviews by ~265%.

➜ **Operational risk is highly concentrated**  
Only ~2% of sellers account for ~22% of revenue exposed to delay risk.

➜ **Logistics bottlenecks are route-specific**  
14 delivery corridors represent ~28% of platform volume.

➜ **Retention is extremely low**  
~94% of GMV comes from one-time buyers.

These insights translate into targeted operational and growth strategies documented in the **Executive Summary section of the analysis notebook**.

These insights translate into targeted operational and growth strategies discussed in the [Executive Summary](./notebooks/olist-retention-logistics-risk.md#5-olist-e-commerce-operations-analysis-executive-summary).

---

# Tools Used

**Data Warehouse and Processing:** Google BigQuery  

**Analysis Environment and Statistical Analysis:** R (Kaggle Notebook)

**Core Libraries:**

- bigrquery
- DBI
- dplyr
- ggplot2
- lubridate

**Visualization:** *ggplot2*

**Version control:** Git and GitHub

---

## Execution Environment

The analysis notebook was executed on Kaggle using a **pinned environment snapshot (2024-07-11)** to ensure package stability and reproducibility.

Runtime details:

- Platform: Kaggle Notebooks
- R version: 4.4.0
- Operating system: Ubuntu 22.04
- Data warehouse: Google BigQuery
- BigQuery interface: `bigrquery` R package

The Kaggle notebook runs in a **non-persistent container**, meaning each execution starts from a clean environment. All datasets used in the analysis are stored in Google BigQuery rather than written to the local filesystem.

---

## Reproducibility

- 📄 [Run Instructions](reproducibility/run_instructions.md)
- 🔗 [BigQuery Connection Setup](reproducibility/bigquery_connection.md)
- 🛠️ [Helper Functions](docs/helper_functions.md)
- 📚 [Data Dictionary](docs/data_dictionary.md)

---

## Analytical Methodology

EDA ➜ feature engineering ➜ segmentation ➜ hypothesis testing ➜ business insights

---

## Project Architecture

![architecture](assets/project_architecture.png)

---

## Project Layout at a Glance

[diagram remains unchanged]

---

# Repository Structure

[tree remains unchanged]

---

## Documentation Workflow

Project reports for this repository were drafted using an AI-assisted documentation workflow with Google NotebookLM to structure and summarize analytical outputs. All analytical logic, code, and results were independently validated and written by the author.
