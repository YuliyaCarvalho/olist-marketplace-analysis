# Data Modeling Decisions

This document serves to record key modeling choices used in the Power BI dashboard to ensure consistency, interpretability and analytical reliability.

---

## 1. Date Dimension (`dim_date`)

A dedicated date table was created to standardize all time-based analysis across the dashboard.

The dashboard relies on monthly trends, reporting-period slicers, month-over-month (MoM) comparisons, and calendar-based groupings. Using raw transaction timestamps directly in visuals leads to duplicated logic and inconsistent time definitions. The `dim_date` table centralizes all time-related logic in a single reusable structure.

**Purpose:**

> - Ensures consistent definitions of year, month, quarter, and weekday across all visuals   
> - Enables properly sorted month labels (e.g., `Jan 2018`)    
> - Supports reusable time-intelligence calculations such as MoM growth    
> - Maintains a clean star-schema design with shared dimensions    
> - Reduces duplication of date logic in measures and visuals    

### DAX

```DAX
dim_date = 
ADDCOLUMNS(
    CALENDAR(
        MIN(orders_final[order_purchase_timestamp]),
        MAX(orders_final[order_purchase_timestamp])
    ),
    "Year", YEAR([Date]),
    "Month Number", MONTH([Date]),
    "Month Name", FORMAT([Date], "MMMM"),
    "Month Short", FORMAT([Date], "MMM"),
    "Quarter", "Q" & FORMAT([Date], "Q"),
    "YearMonth", FORMAT([Date], "YYYY-MM"),
    "YearMonth Label", FORMAT([Date], "MMM YYYY"),
    "Month Start", DATE(YEAR([Date]), MONTH([Date]), 1),
    "Weekday Number", WEEKDAY([Date], 2),
    "Weekday Name", FORMAT([Date], "dddd")
)
```

## 2. Reporting Window for Time-Series Visuals

Certain time-series visuals exclude unstable edge periods in the dataset.

The Olist dataset contains:
> * Sparse early activity in late 2016  
> * Incomplete tail records in September–October 2018  

Including these periods can distort trends, especially for growth rates.

**Standard Reporting Window:** Most trend-based visuals use `January 2017 – August 2018`

**Rationale:**

> * Late 2016 has very low transaction volume, which distorts trend interpretation  
> * January 2017 represents the start of stable monthly activity  
> * September–October 2018 are incomplete due to dataset cutoff  
> * Removing edge periods improves comparability and avoids misleading signals  

---

## 3. Visual-Specific Time Windows

Different visuals apply slightly different reporting windows depending on the metric.

### Marketplace Growth: Net GMV and Order Volume
- Uses the stable reporting period through August 2018  
- Excludes incomplete tail months (September–October 2018)  

**Purpose:** Show overall marketplace growth without distortion from incomplete data.

### Marketplace Momentum: GMV & Orders MoM %
Uses `February 2017 – August 2018`

**Reason:** MoM calculations require a prior month, and early low-volume months produce unstable percentage changes.


### Customer Base Growth
Excludes September–October 2018

**Reason:** Dataset tail is incomplete and does not reflect true customer behavior.

---

## 4. Time Axis Design

Monthly visuals use: `dim_date[Month Start]` as the axis field.

**Rationale:**
> * Ensures correct chronological ordering  
> * Avoids alphabetical sorting issues    
> * Separates display labels from sorting logic  
> * Supports consistent aggregation across visuals  


---

## 5. Purchase Date as Reporting Anchor

The dashboard uses `orders_final[order_purchase_timestamp]` as the primary date for marketplace trend analysis.

**Rationale:**  
> * Represents customer demand timing, not fulfillment timing  
> * Aligns GMV, order volume and customer metrics to purchase behavior  
> * Prevents distortion caused by delivery lag in trend visuals  

Delivery and processing timestamps are used separately for operational metrics (e.g., delivery time, delays), but not for core trend analysis.
