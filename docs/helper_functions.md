# Helper Functions

This project uses several helper functions to simplify the execution of SQL queries in the Kaggle notebook environment connected to **Google BigQuery**.

These utilities eliminate repetitive connection code and standardize how query results are previewed and returned during the analysis workflow.

The functions are designed around **two main dimensions**:

- **Result size**
  - small result sets
  - large result sets

- **Output format**
  - long/tabular format
  - wide format (many columns)

All helper functions execute a SQL query in BigQuery, download the results into an **R data frame**, and return the full data frame for further analysis or visualization.

---

### 1. `run_small_query()`

Executes a SQL query and prints the **full result table** directly in the notebook output.

This function is useful for:

- small result sets
- long/tabular outputs
- quick inspections of query results

### Function

```r
run_small_query <- function(sql) {

  df <- bq_table_download(
    bq_project_query(project_id, sql)
  )

  print(as.data.frame(df))

  return(df)

}
```

### Behavior

- Executes the SQL query in BigQuery
- Downloads the entire result set
- Prints the complete table in the notebook
- Returns the full data frame for further processing

---

### 2. `run_small_query_wide()`

Executes a SQL query and displays the result using R’s **interactive data viewer**.

This function is useful for:

- small datasets
- wide-format tables
- situations where many columns need to be inspected

### Function

```r
run_small_query_wide <- function(sql) {

  df <- bq_table_download(
    bq_project_query(project_id, sql)
  )

  View(df)

  return(df)

}
```

### Behavior

- Executes the SQL query in BigQuery
- Downloads the full result set
- Opens the result in an interactive spreadsheet-style viewer
- Returns the data frame for further analysis

---

### 3. `run_large_query()`

Executes a SQL query and prints a **controlled preview** of the results.

This function is useful for:

- queries returning large datasets
- quick inspection without flooding the notebook output

### Function

```r
run_large_query <- function(sql, preview_rows = 10) {

  df <- bq_table_download(
    bq_project_query(project_id, sql)
  )

  print(as.data.frame(head(df, preview_rows)))

  return(df)

}
```

### Behavior

- Executes the SQL query in BigQuery
- Downloads the entire result set
- Prints only the **first few rows** (default: 10)
- Returns the complete data frame

This allows additional analysis or visualization using the full dataset while keeping the notebook output manageable.

---

### 4. `run_large_query_wide()`

Executes a SQL query and opens the full dataset in an **interactive viewer**.

This function is intended for:

- large datasets
- wide-format outputs
- visual inspection of many columns

### Function

```r
run_large_query_wide <- function(sql, preview_rows = 10) {

  df <- bq_table_download(
    bq_project_query(project_id, sql)
  )

  View(df)

  return(df)

}
```

### Behavior

- Executes the SQL query in BigQuery
- Downloads the entire dataset
- Opens the dataset in R’s spreadsheet-style viewer
- Returns the full data frame

When exploring large datasets visually, it is recommended to include a **`LIMIT` clause in the SQL query** to restrict the preview size.

To retrieve the entire dataset, simply remove the `LIMIT` clause.

---

# Summary

| Function | Best Use Case |
|--------|--------|
| `run_small_query()` | small long-format tables printed in notebook |
| `run_small_query_wide()` | small wide-format tables inspected via viewer |
| `run_large_query()` | large datasets with preview output |
| `run_large_query_wide()` | large wide datasets explored interactively |

These helper utilities improve the efficiency of the analysis workflow by standardizing how SQL queries are executed and inspected within the notebook environment.