# BigQuery Connection Setup

> Infrastructure documentation describing how the Kaggle notebook connects to Google BigQuery.

This project queries the **Olist Brazilian E-Commerce dataset** stored in **Google BigQuery**.  
All analytical queries executed in the Kaggle R notebook access tables within this BigQuery project.

---

# Project Configuration

**Google Cloud Project** -> `olist-project-yuliacarvalho`

**Dataset** -> `Olist_datasets`

The Kaggle notebook connects to BigQuery using **two complementary approaches**:

1. High-level query execution using the **bigrquery** package  
2. A persistent database connection using the **DBI** interface

The first method was primarily used during **data preparation and exploratory analysis**, while the second method was used during the **analysis and visualization phases**.

---

# 1. Initial Configuration

The notebook begins by loading the `bigrquery` package and defining the Google Cloud project ID.

```r
library(bigrquery)

project_id <- "olist-project-yuliacarvalho"
```

This variable is used throughout the notebook when executing queries against BigQuery.

---

# 2. Method A — High-Level bigrquery Queries

For quick data exploration and small queries, the notebook uses helper functions built on top of **bq_project_query()** and **bq_table_download()**.

These functions allow SQL queries to be executed directly in BigQuery and returned as **R data frames**.

### Example Helper Function

```r
run_small_query <- function(sql) {

  df <- bq_table_download(
    bq_project_query(project_id, sql)
  )

  print(as.data.frame(df))
  return(df)

}
```
Additional helper utilities used in the notebook are documented in: `docs/helper_functions.md`
**Purpose of this approach**

- Execute lightweight queries  
- Preview data during the **Prepare and Process phases**  
- Quickly download small result sets into R  

---

# 3. Method B — Persistent Database Connection (DBI)

During the **Analyze and Visualize phase**, a more structured database connection was established using the **DBI interface**.

This approach creates a **persistent connection object** linked to a specific dataset within the BigQuery project.

### Establishing the Connection

```r
library(DBI)

connection <- dbConnect(
  bigrquery::bigquery(),
  project = "olist-project-yuliacarvalho",
  dataset = "Olist_datasets"
)
```

This connection allows SQL queries to be executed directly using standard database functions.

---

# 4. Querying Data from BigQuery

Once the connection is established, tables can be loaded into the R environment using **dbGetQuery()**.

### Example

```r
products <- dbGetQuery(
  connection,
  "SELECT * FROM `olist-project-yuliacarvalho.Olist_datasets.products_final`"
)
```

This command executes the SQL query in BigQuery and returns the result as an R data frame.

---

# Technical Notes

## Authentication

Authentication is handled automatically through the **Kaggle notebook environment**, which prompts Google account authorization when accessing BigQuery resources.

---

## Data Storage Strategy

During early experimentation, external **Google Drive tables** were considered for data access.

However, this approach produced **credential and access issues** within the Kaggle environment.

To improve reliability, all source files were imported into **BigQuery as native tables**.

Advantages of this approach include:

- improved query performance  
- more stable authentication  
- simplified dataset management  
- better compatibility with Kaggle notebooks  

---

# Summary

The analysis pipeline uses **BigQuery as the primary data warehouse**, with the Kaggle R notebook acting as the analysis layer.

Two connection strategies were used:

| Method | Purpose |
|------|------|
| `bigrquery` helper queries | quick exploration and small result sets |
| `DBI` persistent connection | structured querying during analysis and visualization |

This architecture enables **scalable query execution in BigQuery while maintaining a flexible R-based analysis workflow.**