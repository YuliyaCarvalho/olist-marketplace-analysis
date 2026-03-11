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

Complete Notebook: [Olist: Retention, Logistics & Risk](https://www.kaggle.com/code/yuliyacarvalho/olist-retention-logistics-risk)  

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

<img src="assets/project_architecture.png" width="700">

---

## Project Layout at a Glance

```text
                             olist-marketplace-analysis
                                        │
        ┌────────────────────────────────┼────────────────────────────────┐
        │                                │                                │
        │                                │                                │
     README.md                        assets                         notebooks
        │                                │                                │
        │                                │                                ├── .ipynb
        │                                │                                ├── .html
        │                                │                                └── .pdf
        │                                │
        │                                └── project_architecture.png
        │
        ├──────────────────────┬──────────────────────┬───────────────────┐
        │                      │                      │                   │
        │                      │                      │                   │
business_questions       sql_cleaning         reproducibility          docs
        │                      │                      │
        │                      │                      ├── bigquery_connection.md
        │                      │                      └── run_instructions.md
        │                      │
        │                      ├── customers_cleaning.sql
        │                      ├── sellers_cleaning.sql
        │                      ├── products_cleaning.sql
        │                      ├── orders_cleaning.sql
        │                      ├── order_items_cleaning.sql
        │                      ├── payment_cleaning.sql
        │                      ├── reviews_cleaning.sql
        │                      └── geolocations_cleaning.sql
        │
        ├── 01_marketplace_growth
        ├── 02_customer_behavior
        ├── 03_operations_and_logistics
        └── 04_profitability_and_risk
                               │
                               │
                  Each question folder follows the same pattern:
                               │
                               └── q0X_question_name
                                   ├── q0X_README.md
                                   └── q0X_dataviz

---

# Repository Structure

# Repository Structure

.
├── README.md
├── assets
│   └── project_architecture.png
│
├── business_questions
│   ├── README.md
│   │
│   ├── 01_marketplace_growth
│   │   ├── q01_gmv_trends
│   │   │   ├── q01_README.md
│   │   │   └── q01_dataviz
│   │   │
│   │   ├── q02_order_volume_trends
│   │   │   ├── q02_README.md
│   │   │   └── q02_dataviz
│   │   │
│   │   ├── q03_delivery_reliability_trends
│   │   │   ├── q03_README.md
│   │   │   └── q03_dataviz
│   │   │
│   │   ├── q04_seller_product_concentration
│   │   │   ├── q04_README.md
│   │   │   └── q04_dataviz
│   │   │
│   │   └── q05_category_gmv_mix
│   │       ├── q05_README.md
│   │       └── q05_dataviz
│   │
│   ├── 02_customer_behavior
│   │   ├── q06_repeat_customer_share
│   │   │   ├── q06_README.md
│   │   │   └── q06_dataviz
│   │   │
│   │   ├── q07_repeat_customer_unit_economics
│   │   │   ├── q07_README.md
│   │   │   └── q07_dataviz
│   │   │
│   │   ├── q08_customer_order_distribution
│   │   │   ├── q08_README.md
│   │   │   └── q08_dataviz
│   │   │
│   │   ├── q09_repeat_customer_demographics
│   │   │   ├── q09_README.md
│   │   │   └── q09_dataviz
│   │   │
│   │   └── q10_category_mix_by_repeat_segment
│   │       ├── q10_README.md
│   │       └── q10_dataviz
│   │
│   ├── 03_operations_and_logistics
│   │   ├── q11_delivery_speed_vs_repeat_rate
│   │   │   ├── q11_README.md
│   │   │   └── q11_dataviz
│   │   │
│   │   ├── q15_operational_drivers_of_reviews
│   │   │   ├── q15_README.md
│   │   │   └── q15_dataviz
│   │   │
│   │   ├── q16_holiday_delay_impact
│   │   │   ├── q16_README.md
│   │   │   └── q16_dataviz
│   │   │
│   │   ├── q17_geographic_delivery_performance
│   │   │   ├── q17_README.md
│   │   │   └── q17_dataviz
│   │   │
│   │   └── q18_product_size_vs_logistics
│   │       ├── q18_README.md
│   │       └── q18_dataviz
│   │
│   └── 04_profitability_and_risk
│       ├── q12_reviews_vs_repeat_rate
│       │   ├── q12_README.md
│       │   └── q12_dataviz
│       │
│       ├── q13_revenue_by_repeat_segment
│       │   ├── q13_README.md
│       │   └── q13_dataviz
│       │
│       └── q14_churn_by_review_score
│           ├── q14_README.md
│           └── q14_dataviz
│
├── notebooks
│   ├── olist-retention-logistics-risk.ipynb
│   ├── olist-retention-logistics-risk.html
│   └── olist-retention-logistics-risk.pdf
│
├── reproducibility
│   ├── bigquery_connection.md
│   └── run_instructions.md
│
└── sql_cleaning
    ├── customers_cleaning.sql
    ├── geolocations_cleaning.sql
    ├── order_items_cleaning.sql
    ├── orders_cleaning.sql
    ├── payment_cleaning.sql
    ├── products_cleaning.sql
    ├── reviews_cleaning.sql
    └── sellers_cleaning.sql

---

## Documentation Workflow

Project reports for this repository were drafted using an AI-assisted documentation workflow with Google NotebookLM to structure and summarize analytical outputs. All analytical logic, code, and results were independently validated and written by the author.
