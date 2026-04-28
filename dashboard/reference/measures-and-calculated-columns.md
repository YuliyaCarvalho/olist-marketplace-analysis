# Olist Dashboard — Measures and Calculated Columns

## Purpose of this file

This file serves as the central dictionary for all measures and calculated columns used in the Olist Power BI dashboard.

It documents:

- the business meaning of each metric or field
- whether it is a **measure** or a **calculated column**
- where it is used in the dashboard
- the DAX definition
- important logic notes
- interpretation caveats


---

## How to use this dictionary

Each entry follows the same structure:

- **Display Name** — the name shown or referenced in the dashboard
- **Type** — Measure or Calculated Column
- **Table** — where the object lives
- **Used in Pages** — where it appears in the report
- **Business Definition** — plain-English meaning
- **DAX** — exact formula
- **Logic Notes** — technical explanation of how it works
- **Scope Notes** — defining characteristics of the metric

---

# Core Measures - A

## actual-delivery-days

- **Display Name:** Actual Delivery Days
- **Type:** Measure
- **Table:** _Measures
- **Used in Pages:** Operations Overview

**Business Definition:**
Calculates the average number of days between order purchase and actual customer delivery for delivered orders with valid timelines.

**DAX:**
```DAX
Actual Delivery Days = 
CALCULATE(
    AVERAGE(orders_final[order_to_delivery_days]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0
)
```

**Logic Notes:**

➡︎ Uses `orders_final[order_to_delivery_days]` as the realized delivery duration field
➡︎ Restricts the cohort to delivered orders only, excludes invalid timeline sequences using `timeline_is_valid = 1` and hanging or operationally abnormal orders using `is_hanging = 0`
➡︎ Returns the average actual end-to-end delivery time across visible orders

**Scope Notes:**

* This is a period-sensitive actual fulfillment-speed metric
* It responds to page filters such as Reporting Period, Customer Region, and Order Type
* It represents realized delivery performance rather than promised delivery timing
* It is best interpreted alongside Estimated Delivery Days

---

## approval-to-carrier-p90

- **Display Name:** Approval To Carrier P90
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Calculates the platform-wide 90th percentile of **approval-to-carrier time** across eligible orders, providing the benchmark used to define extreme processing delay.

**DAX:**
```DAX
Approval To Carrier P90 = 
CALCULATE(
    PERCENTILEX.INC(
        FILTER(
            orders_final,
            NOT ISBLANK(orders_final[Approval To Carrier (Days Decimal)])
        ),
        orders_final[Approval To Carrier (Days Decimal)],
        0.90
    ),
    REMOVEFILTERS(sellers_final)
)
```

**Logic Notes:**

➡︎ Uses PERCENTILEX.INC to calculate the 90th percentile of Approval To Carrier (Days Decimal)
➡︎ Restricts the benchmark to orders where approval-to-carrier duration is not blank
➡︎ Uses REMOVEFILTERS(sellers_final) so the threshold remains platform-wide rather than seller-specific
➡︎ Provides the cutoff used to identify unusually slow processing cases in seller rankings

**Scope Notes:**

* This is a benchmark measure, not a seller-performance measure by itself
* It is used as the threshold reference for `Slow Processed Orders (P90)`
* It should be interpreted as the platform standard for extreme seller-side processing delay
* It remains stable across sellers within the same broader page context

---

## average-orders-per-customer

- **Display Name:** Average Orders per Customer
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the average number of **valid delivered orders** placed per **valid customer** in the current filter context.

**DAX:**
```DAX
Average Orders per Customer = 
DIVIDE(
    [Valid Delivered Orders],
    [Valid Customers]
)
```

**Logic Notes:**

➡︎ Uses [`Valid Delivered Orders`](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders) as the numerator
➡︎ Uses [`Valid Customers`](./olist-dashboard-measures-and-calculated-columns.md#valid-customers) as the denominator
➡︎ Measures average purchase frequency within the cleaned valid-order cohort
➡︎ Inherits all filtering logic from the two supporting measures
➡︎ Returns the average number of valid orders per distinct valid customer

**Scope Notes:**

This is a period-sensitive behavioral KPI
It responds to the Reporting Period slicer, year bookmark buttons, and Customer Region
It should be interpreted as average observed order frequency within the selected context
It does not classify customers as repeat or non-repeat; it summarizes overall ordering intensity

---

## aov

- **Display Name:** AOV
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview, Customer Behavior Overview

**Business Definition:**  
Calculates the average **Net GMV** generated per **valid delivered order** in the current filter context. It represents the dashboard’s main cleaned order-level value metric and reflects average billed spend per completed qualifying order.

**DAX:**
```DAX
AOV = 
DIVIDE(
    [Net GMV],
    [Valid Delivered Orders]
)
```

**Logic Notes:**

➡︎ Uses [`Net GMV`](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) as the numerator  
➡︎ Uses [`Valid Delivered Orders`](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders) as the denominator  
➡︎ Measures average order-level monetization within the cleaned commercial cohort  
➡︎ Inherits all cleaning and validity rules from the supporting measures  
➡︎ Returns the average billed value per **valid delivered order**  
➡︎ Because [`Net GMV`](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) is based on `payment_value`, this metric includes freight and reflects billed order value rather than item price alone  

**Scope Notes:**

* This is the dashboard’s main cleaned order-level value metric
* It is period-sensitive and responds to filters such as `Reporting Period`, year bookmark buttons, and `Customer Region`
* It is restricted to the same valid delivered order cohort used across the core analytical pages
* It should be interpreted as average value per qualifying order, not per customer or per item
* It is distinct from customer-level metrics such as GMV per Customer

---

## approval-to-carrier-days-decimal

- **Display Name:** Approval To Carrier (Days Decimal)
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Calculates the elapsed time, in days, between **order approval** and **carrier handoff** for valid single-seller orders.

**DAX:**
```DAX
Approval To Carrier (Days Decimal) = 
VAR Approved = orders_final[order_approved_at]
VAR Carrier = orders_final[order_delivered_carrier_date]
RETURN
    IF(
        orders_final[timeline_is_valid] = 1 &&
        orders_final[Order Type] = "Single-Seller" &&
        NOT ISBLANK(Approved) &&
        NOT ISBLANK(Carrier),
        Carrier - Approved,
        BLANK()
    )
```

**Logic Notes:**

➡︎ Uses `order_approved_at` as the start timestamp
➡︎ Uses `order_delivered_carrier_date` as the end timestamp
➡︎ Returns a decimal day interval by subtracting the two datetime values directly
➡︎ Includes only orders with `timeline_is_valid = 1`
➡︎ Includes **only Single-Seller orders** to keep seller attribution clean
➡︎ Returns BLANK() if either timestamp is missing

**Scope Notes:**

* This is an order-level pre-shipment processing field
* It is evaluated at model refresh
* It is designed to isolate seller-side processing performance before delivery begins
* It **excludes multi-seller orders** because a single order-level carrier timestamp cannot be cleanly attributed across multiple sellers

---

## avg-delivery-time-days

- **Display Name:** Avg Delivery Time (Days)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview, Operations Overview

**Business Definition:**  
Calculates the average number of days from order purchase to customer delivery for **valid delivered orders** in the current filter context.

**DAX:**
```DAX
Avg Delivery Time (Days) = 
CALCULATE(
    AVERAGE(orders_final[order_to_delivery_days]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Uses `orders_final[order_to_delivery_days]` as the underlying duration field
➡︎ Includes only orders with `order_status = "delivered"`
➡︎ Excludes records failing the chronological quality check with `timeline_is_valid = 1`
➡︎ Excludes hanging or operationally abnormal orders using `is_hanging = 0`
➡︎ Excludes zero-value and micro-value transactions by requiring `payment_value >= 1`
➡︎ Returns the average end-to-end delivery time across the cleaned operational cohort

**Scope Notes:**

* This is a period-sensitive fulfillment-speed metric
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It should be interpreted as average actual delivery time, not promised delivery time
* It is often used alongside lateness metrics to distinguish absolute speed from deadline performance

---

## avg-review-score

- **Display Name:** Avg Customer Rating
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates the average non-blank customer review score in the current filter context, using the 1-to-5 star ratings stored in `order_review_final[review_stars]`.

**DAX:**
```DAX
Avg Review Score =
AVERAGEX(
    FILTER(order_review_final, NOT ISBLANK(order_review_final[review_stars])),
    order_review_final[review_stars]
)
```

**Logic Notes:**

➡︎ Uses `order_review_final[review_stars]` as the underlying satisfaction field 
➡︎ Averages only submitted review values (`review_stars`), preventing missing ratings from distorting the result  
➡︎ Returns a continuous customer-satisfaction metric on the original 1-to-5 review scale  
➡︎ Reflects customer rating sentiment in the current filter context
➡︎ Does not restrict reviews to the dashboard’s valid delivered order cohort unless those filters are added separately through page, visual, or model context

**Scope Notes:**

* This is a broad review-based customer satisfaction metric
* It reflects available review records, **not on the dashboard’s valid delivered order** cohort
* Reviews in the Olist dataset are not limited to delivered orders, so this metric can include ratings associated with other order statuses
* Because review submission is optional, this metric summarizes reviewed orders only, not the full order population

---

## avg-review-score-delay-cohort-benchmark

- **Display Name:** Avg Review Score (Delay Cohort Benchmark)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Represents the average non-blank customer review score for the delivered, timeline-valid order cohort that can be classified into a non-blank [`orders_final[Delay Category]`](./olist-dashboard-measures-and-calculated-columns.md#delay-category). It is used as a benchmark line for comparing review scores across delay-severity groups.

**DAX:** 
```DAX
Avg Review Score (Delay Cohort Benchmark) =
CALCULATE(
    AVERAGEX(
        FILTER(order_review_final, NOT ISBLANK(order_review_final[review_stars])),
        order_review_final[review_stars]
    ),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    NOT ISBLANK(orders_final[Delay Category])
)
```

**Logic Notes:**

➡︎ Uses `order_review_final[review_stars]` as the underlying satisfaction field  
➡︎ Excludes blank review scores before aggregation  
➡︎ Restricts the benchmark to delivered orders and to timeline-valid deliveries using `orders_final[timeline_is_valid] = 1` only
➡︎ Restricts the benchmark to orders with a non-blank [`orders_final[Delay Category]`](./olist-dashboard-measures-and-calculated-columns.md#delay-category), ensuring cohort comparability with the bars in the delay-severity chart  
➡︎ Provides a benchmark that is analytically aligned with the delay-based comparison visual rather than with the broader review population  

**Scope Notes:**

* This is a reusable benchmark measure for delay-severity analysis
* It responds to page filters such as `Customer Region`, `Reporting Period`, and year button selections
* It is evaluated within the current visual and filter context, subject to its internal cohort restrictions
* Higher values indicate better average customer satisfaction within the delay-eligible delivered cohort
* It is intended primarily for use as a reference line in the `Average Review Score by Delay Severity` chart

---

## avg-delivery-gap-vs-eta

- **Display Name:** Avg Delivery Gap vs ETA
- **Type:** Visual Aggregation
- **Table:** `orders_final`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Represents the average number of days between the **estimated delivery date** and the **actual customer delivery date** for delivered orders with valid timeline sequencing in the current filter context.

**Field / Aggregation:**  `orders_final[delay_vs_eta]` aggregated as **Average**

**Visual-level Filters:**

- `orders_final[order_status] = "delivered"`
- `orders_final[timeline_is_valid] = 1`

**Logic Notes:**

➡︎ Uses `orders_final[delay_vs_eta]` as the underlying timing-gap field  
➡︎ Aggregates the field using **Average** directly in the visual rather than through a standalone measure  
➡︎ Restricts the result to delivered orders only  
➡︎ Excludes records with invalid timeline sequencing using `timeline_is_valid = 1`  
➡︎ Returns the average delivery gap relative to the estimated promise date  
➡︎ Negative values indicate delivery earlier than estimated, while positive values indicate delivery later than estimated  

**Scope Notes:**

* This is a period-sensitive schedule-performance visual metric
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It is not implemented as a reusable DAX measure in `_Measures`
* Negative values mean the marketplace is delivering earlier than promised on average
* Positive values mean the marketplace is missing the estimated timeline on average

---



# Core Measures - C

## customer-frequency-table

- **Display Name:** customer_frequency
- **Type:** Calculated Table
- **Table:** `customer_frequency`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Creates a customer-level summary table that counts how many orders each customer placed across the dataset.

**DAX:**
```DAX
customer_frequency = 
SUMMARIZE(
    orders_final,
    orders_final[customer_unique_id],
    "orders_per_customer", DISTINCTCOUNT(orders_final[order_id])
)
```

**Logic Notes:**

➡︎ Aggregates data to one row per `customer_unique_id`
➡︎ Calculates orders_per_customer as the distinct count of `order_id` per customer
➡︎ Provides the base structure for customer frequency segmentation
➡︎ Is built from `orders_final` and therefore reflects whatever order universe exists in that table

**Scope Notes:**

* This is a model-support table, not a reporting measure
* It is used to classify customers into behavioral frequency segments
* It is evaluated at refresh time rather than dynamically during report interaction
* If no additional filters are built into the table definition, segmentation reflects the full order history present in orders_final

---


## customer-frequency-customer-segment

- **Display Name:** Customer Segment
- **Type:** Calculated Column
- **Table:** `customer_frequency`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Classifies each customer into a purchase-frequency segment based on the number of distinct orders they placed.

**DAX:**
```DAX
Customer Segment = 
SWITCH(
    TRUE(),
    customer_frequency[orders_per_customer] = 1, "One-time buyers",
    customer_frequency[orders_per_customer] = 2, "Light repeat buyers",
    customer_frequency[orders_per_customer] >= 3, "Heavy repeat buyers"
)
```
**Logic Notes:**

➡︎ Uses orders_per_customer as the segmentation driver
➡︎ Assigns customers with exactly 1 order to One-time buyers
➡︎ Assigns customers with exactly 2 orders to Light repeat buyers
➡︎ Assigns customers with 3 or more orders to Heavy repeat buyers
➡︎ Creates an interpretable behavioral segmentation layer for customer-value analysis

**Scope Notes:**

* This is a static segmentation column evaluated at model refresh
* It is used to separate revenue and customer behavior by purchase frequency
* It supports measures such as `Repeat Customer GMV`
* Its meaning depends on the order universe used to create orders_per_customer

---

## customer-segment-table

- **Display Name:** Customer Segment Table
- **Type:** Calculated Table
- **Table:** `Customer Segment Table`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Creates a small disconnected helper table containing the three customer purchase-frequency segments used in customer behavior visuals.

**DAX:**
```DAX
Customer Segment Table = 
DATATABLE(
    "Customer Segment", STRING,
    {
        {"One-time Buyers"},
        {"Light Repeat Buyers"},
        {"Heavy Repeat Buyers"}
    }
)
```
**Logic Notes:**

➡︎ Creates a fixed three-row segment list
➡︎ Is used to display customer frequency segments in a controlled and consistent order
➡︎ Acts as a disconnected presentation table rather than a transactional data source
➡︎ Supports dynamic measure switching for segment-based visuals

**Scope Notes:**

* This is a helper table for report display logic
* It is static and evaluated at model refresh
* It does not store customer-level facts
* Its text labels must exactly match the labels referenced in dependent measures

---

## customer-share-percent

- **Display Name:** Customer Share %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Returns the customer share associated with the selected purchase-frequency segment.

**DAX:**
```DAX
Customer Share % = 
SWITCH(
    SELECTEDVALUE('Customer Segment Table'[Customer Segment]),
    "One-time Buyers", [One-time Buyer Share %],
    "Light Repeat Buyers", [Light-repeat Buyer Share %],
    "Heavy Repeat Buyers", [Heavy-repeat Buyer Share %]
)
```

**Logic Notes:**

➡︎ Uses SELECTEDVALUE to detect the current segment label from Customer Segment Table
➡︎ Returns the corresponding segment-share measure for that selected label
➡︎ Enables a single visual to display multiple customer-segment share measures through one dynamic metric
➡︎ Depends on exact text matching between the segment table values and the SWITCH conditions

**Scope Notes:**

* This is a display-routing measure rather than a base business metric
* It is used to unify segment-specific measures into one chart
* It is sensitive to page filters through the supporting share measures
* Its correctness depends on label consistency between the helper table and the SWITCH statement

---

## customer-region-gmv-percent

- **Display Name:** Customer Region GMV %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates each customer region’s share of total `Net GMV` in the current page context.

**DAX:**
```DAX
Customer Region GMV % =
DIVIDE(
    [Net GMV],
    CALCULATE([Net GMV], ALL(customers_final[Customer Region]))
)
```

**Logic Notes:**

➡︎ Uses regional `Net GMV` as the numerator
➡︎ Uses total `Net GMV` across all customer regions as the denominator
➡︎ Removes only the Customer Region filter in the denominator while preserving the rest of the current page context
➡︎ Returns each region’s contribution as a proportion of **total regional Net GMV**

**Scope Notes:**

* This is a share-of-total metric within the current page context
* It is sensitive to slicers and page filters, but not to the regional breakdown itself in the denominator
* It is used to complement the absolute `Net GMV` bars with relative contribution information

---

## customer-region

- **Display Name:** Customer Region
- **Type:** Calculated Column
- **Table:** `customers_final`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Groups Brazilian customer states into broader geographic regions for higher-level comparison.

**DAX:**
```DAX
Customer Region =
SWITCH(
    TRUE(),
    customers_final[customer_state] IN {"SP","RJ","MG","ES"}, "Southeast",
    customers_final[customer_state] IN {"RS","SC","PR"}, "South",
    customers_final[customer_state] IN {"BA","SE","AL","PE","PB","RN","CE","PI","MA"}, "Northeast",
    customers_final[customer_state] IN {"GO","DF","MT","MS"}, "Central-West",
    customers_final[customer_state] IN {"AM","RR","AP","PA","TO","RO","AC"}, "North",
    "Unknown"
)
```

**Logic Notes:**

➡︎ Maps each `customer_state` to one of five Brazilian macro-regions
➡︎ Assigns "Unknown" when the state does not match any defined region group
➡︎ Simplifies geographic analysis by reducing state-level granularity into broader regional segments

``Scope Notes:``

* This column is used for executive-level and comparative geography visuals
* It improves readability and reduces sparsity compared with state-level breakdowns
* It hides within-region variation and should not be used for detailed state-level diagnostics

---

## category-gmv-percent

- **Display Name:** Category GMV %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates each product category’s share of total `Net GMV`, using a denominator that removes all filters from `products_final`.

**DAX:**
```DAX
Category GMV % = 
DIVIDE(
    [Net GMV],
    CALCULATE([Net GMV], ALL(products_final))
)
```

**Logic Notes:**

➡︎ Uses category-level `Net GMV` as the numerator
➡︎ Uses total `Net GMV` with all `products_final` filters removed as the denominator
➡︎ Removes product-table filters in the denominator, not just the category breakdown
➡︎ Returns each category’s contribution as a proportion of total `Net GMV` outside product-level filtering

**Scope Notes:**

* This is a share-of-total metric with a product-table-reset denominator
* It does not preserve filters coming from `products_final` in the denominator
* If product-related slicers are used on the page, the percentage may not reflect share within the currently selected product subset

---

# Core Measures - D

## delay-vs-eta

- **Display Name:** delay_vs_eta
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Operations Overview, Customer Experience Overview

**Business Definition:**  
Calculates the day-level difference between the estimated delivery date and the actual customer delivery date for each order.

**DAX:**
```DAX
delay_vs_eta = 
VAR Actual =
    orders_final[order_delivered_customer_date]
VAR Estimated =
    orders_final[order_estimated_delivery_date]
RETURN
    IF(
        NOT ISBLANK(Actual)
            && NOT ISBLANK(Estimated),
        DATEDIFF(Estimated, Actual, DAY),
        BLANK()
    )
```

**Logic Notes:**

➡︎ Uses `order_estimated_delivery_date` as the reference point; uses `order_delivered_customer_date` as the actual outcome
➡︎ Calculates DATEDIFF(Estimated, Actual, DAY)
➡︎ Returns negative values when delivery happens before the estimate; returns positive values when delivery happens after the estimate
➡︎ Returns BLANK() if either date is missing

**Scope Notes:**

* This is an order-level timing deviation field
* It is evaluated at model refresh
* It supports both average timing-gap KPIs and delivery-delay segmentation
* Its interpretation depends on the sign: negative is earlier-than-estimated, positive is later-than-estimated

---

## delay-vs-eta-decimal

- **Display Name:** delay_vs_eta_decimal
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Operations Overview, Logistics Overview, Customer Experience

**Business Definition:**  
Calculates the difference between the **estimated delivery date** and the **actual customer delivery timestamp** in **decimal days**, allowing delivery timing to be measured with sub-day precision rather than as a rounded whole-day interval.

**Column Expression:** `orders_final[delay_vs_eta_decimal]`

```DAX
delay_vs_eta_decimal = 
VAR Actual = orders_final[order_delivered_customer_date]
VAR Estimated = orders_final[order_estimated_delivery_date]
RETURN
    IF(
        NOT ISBLANK(Actual) && NOT ISBLANK(Estimated),
        DIVIDE(DATEDIFF(Estimated, Actual, SECOND), 86400),
        BLANK()
    )
```

**Logic Notes:**

➡︎ Uses `orders_final[order_estimated_delivery_date]` as the promised delivery timestamp and `orders_final[order_delivered_customer_date]` as the actual delivery timestamp  
➡︎ Computes the gap in **seconds** using `DATEDIFF(..., SECOND)` and then converts that result to **days** by dividing by `86400`  
➡︎ Returns negative values when the order was delivered earlier than estimated and positive values when it was delivered later than estimated  
➡︎ Preserves fractional-day precision, making the metric more analytically consistent for timing comparisons and averages  
➡︎ Returns `BLANK()` when either the actual or estimated delivery timestamp is missing  

**Scope Notes:**

* This is a reusable delivery-timing precision column
* It is evaluated row by row in `orders_final`
* It is intended for analyses where timing precision matters more than coarse whole-day bucketing
* It is especially useful when aligning Power BI outputs with notebook-based analysis performed outside Power BI
* It should be interpreted together with delivery-delay grouping logic and average timing-gap visuals

---

## Why this decimal version was introduced (vs delay_vs_eta calculated column)

The decimal version was created to align Power BI more closely with the timing logic used in the R notebook.

**Reason for the change:**  
`DATEDIFF` in Power BI behaves differently depending on the interval used. When the interval is set to `DAY`, Power BI counts **day boundaries crossed**, which can produce coarse whole-number differences that do not match notebook calculations based on exact timestamp subtraction. In R, datetime differences are typically computed from the full timestamp values and returned as continuous elapsed time, which preserves partial days.

**What this means in practice:**

➡︎ A delivery that is only a few hours late may still be shown as `1` day late in a whole-day `DATEDIFF(..., DAY)` approach  
➡︎ A delivery that is slightly early or slightly late can be overstated or understated when only calendar-day boundaries are counted  
➡︎ R timestamp arithmetic usually reflects the true elapsed interval, including partial days, so Power BI whole-day `DATEDIFF` can drift from notebook results  
➡︎ Using `DATEDIFF(..., SECOND) / 86400` in Power BI makes the calculation behave much more like continuous datetime subtraction in R  
➡︎ This improves consistency between notebook findings and dashboard metrics, especially for averages, benchmarks, and severity thresholds near bucket boundaries  

**Interpretation note:**  
The decimal-day version is more precise and more comparable to notebook analysis, but it may produce slightly different values than earlier Power BI fields built on whole-day `DATEDIFF(..., DAY)` logic. That difference is expected and reflects a methodological improvement rather than an error.

--- 

## delay-bucket-4

- **Display Name:** Delay Bucket 4
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Classifies each order into one of four delivery-performance buckets based on the difference between the **estimated delivery date** and the **actual customer delivery date**, using the underlying [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta) value.

**DAX:** 
```DAX
Delay Bucket 4 = 
VAR d = orders_final[delay_vs_eta]
RETURN
    SWITCH(
        TRUE(),
        ISBLANK(d), BLANK(),
        d > 3, "Severely Late (>3d)",
        d > 0 && d <= 3, "Late (1–3d)",
        d > -3 && d <= 0, "On-Time",
        d <= -3, "Early (≥3d early)"
    )
```

**Logic Notes:**

➡︎ Uses [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta) as the underlying timing-gap field  
➡︎ Returns `Severely Late (>3d)` when the order was delivered more than 3 days after the estimated delivery date  
➡︎ Returns `Late (1–3d)` when the order was delivered between 1 and 3 days after the estimated delivery date  
➡︎ Returns `On-Time` when the order was delivered on time or up to 3 days earlier than estimated  
➡︎ Returns `Early (≥3d early)` when the order was delivered at least 3 days earlier than estimated  
➡︎ Returns `BLANK()` when `delay_vs_eta` is blank, preventing incomplete records from being assigned to a delivery bucket  
➡︎ Converts a continuous timing-gap field into a business-readable categorical severity framework for customer-experience analysis  

**Scope Notes:**

* This is a reusable delivery-performance classification column
* It is evaluated row by row in `orders_final`
* It is primarily used to compare customer satisfaction outcomes across delivery-delay severity groups
* It is best interpreted together with [`orders_final[Delay Bucket 4 Sort]`](./olist-dashboard-measures-and-calculated-columns.md#delay-bucket-4-sort), [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta), and [Low Review %](./olist-dashboard-measures-and-calculated-columns.md#low-review-percent)
* It provides a more behaviorally meaningful grouping than raw delivery-gap values when used in charts and matrices

---

## delay-category

- **Display Name:** Delay Category
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Logistics Overview, Customer Experience

**Business Definition:**  
Classifies each order into a simplified delivery-timing outcome bucket based on the difference between the **estimated delivery date** and the **actual customer delivery date**, using the underlying [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta) value.

**DAX:** 
```DAX
Delay Category = 
VAR d = orders_final[delay_vs_eta]
RETURN
    IF(
        ISBLANK(d), BLANK(),
        IF(
            d <= 0, "On-Time",
            IF(d <= 3, "Late (1–3d)", "Severely Late (>3d)")
        )
    )
```

**Logic Notes:**

➡︎ Uses [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta) as the underlying timing-gap field  
➡︎ Returns `On-Time` when the order was delivered on or before the estimated delivery date  
➡︎ Returns `Late (1–3d)` when the order was delivered 1 to 3 days after the estimated delivery date  
➡︎ Returns `Severely Late (>3d)` when the order was delivered more than 3 days after the estimated delivery date  
➡︎ Returns `BLANK()` when `delay_vs_eta` is blank, preventing incomplete records from being misclassified  
➡︎ Converts a continuous day-gap field into a compact categorical variable for grouped visual analysis and severity-based segmentation  

**Scope Notes:**

* This is a reusable delivery-performance classification column
* It is evaluated row by row in `orders_final`
* It is commonly used in grouped visuals, KPI severity measures, and late-delivery segmentation
* It supports easier interpretation than raw delivery-gap values when comparing delivery outcomes
* It is best interpreted together with [`orders_final[delay_vs_eta]`](./olist-dashboard-measures-and-calculated-columns.md#delay-vs-eta), [Late Delivery Rate %](./olist-dashboard-measures-and-calculated-columns.md#late-delivery-rate-), and [Severely Late (>3d) %](./olist-dashboard-measures-and-calculated-columns.md#severely-late-3d-percent)

---

## delivery-gap-days

**Display Name:** Delivery Gap (Days)
**Type:** Measure
**Table:** _Measures
**Used in Pages:** Operations Overview, Logistics Overview

**Business Definition:**
Calculates the difference between average actual delivery time and average estimated delivery time in the current filter context.

**DAX:**
```DAX
Delivery Gap (Days) = 
[Actual Delivery Days] - [Estimated Delivery Days]
```

**Logic Notes:**

➡︎ Uses `Actual Delivery Days` as the realized delivery benchmark
➡︎ Uses `Estimated Delivery Days` as the promised delivery benchmark
➡︎ Returns the average timing gap between actual and estimated delivery duration
➡︎ Negative values mean actual delivery was faster than the estimated timeline, positive values mean actual delivery was slower than the estimated timeline

**Scope Notes:**

* This is a comparative delivery-performance measure
* It is used in tooltips to make the line-gap interpretation explicit
* It responds to the same filters as the two underlying measures
* It is useful for assessing the size of the delivery buffer relative to promised timelines

---

# Core Measures - E

## estimated-delivery-days

- **Display Name:** Estimated Delivery Days
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Calculates the average number of days between order purchase and the estimated delivery date for delivered orders with valid timelines.

**DAX:**
```DAX
Estimated Delivery Days = 
CALCULATE(
    AVERAGEX(
        orders_final,
        DATEDIFF(
            orders_final[order_purchase_timestamp],
            orders_final[order_estimated_delivery_date],
            DAY
        )
    ),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0
)
```

**Logic Notes:**

➡︎ Uses `DATEDIFF(order_purchase_timestamp, order_estimated_delivery_date, DAY)` at order level
➡︎ Averages the estimated delivery window across visible orders
➡︎ Restricts the cohort to delivered orders only
➡︎ Excludes invalid timeline sequences using `timeline_is_valid = 1` + excludes hanging or operationally abnormal orders using `is_hanging = 0`

**Scope Notes:**

This is a period-sensitive promised-timeline metric
It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
It reflects the expected delivery window promised to the customer, not actual performance
It is best interpreted alongside `Actual Delivery Days`

---


# Core Measures - F

## fulfillment-rate

- **Display Name:** Fulfillment Rate / Order Fulfillment
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates the share of total orders that belong to the dashboard’s **valid delivered order cohort** (proportion of all placed orders that result in clean, completed deliveries — captures end-to-end order success, including operational and data quality failures).

**DAX:**
```DAX
Fulfillment Rate =
DIVIDE([Valid Delivered Orders], [Order Volume])
```

**Logic Notes:**

➡︎ Uses **Valid Delivered Orders** as the numerator
➡︎ Uses **Order Volume** as the denominator
➡︎ Measures the proportion of total orders that were delivered and passed the project’s validity and payment-quality filters
➡︎ Inherits the broader platform scope of **Order Volume** and the stricter cohort logic of **Valid Delivered Orders**

**Scope Notes:**

* This is a blended platform-to-cohort conversion metric, rather than a pure operational SLA metric
* The numerator is restricted to valid delivered orders, while the denominator includes all distinct orders in context
* As a result, this metric reflects both delivery completion and the effect of the dashboard’s data-quality filters

---

# Core Measures - G

## gmv-mom-percent

- **Display Name:** GMV MoM %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates month-over-month percentage change in `Net GMV`.

**DAX:**
```DAX
GMV MoM % =
VAR CurrentGMV = [Net GMV]
VAR PrevGMV =
    CALCULATE(
        [Net GMV],
        DATEADD('dim_date'[Date], -1, MONTH)
    )
RETURN
DIVIDE(CurrentGMV - PrevGMV, PrevGMV)
```

**Logic Notes:**

➡︎ Uses `Net GMV` for the current month as the numerator base
➡︎ Retrieves the previous month’s `Net GMV` using DATEADD('dim_date'[Date], -1, MONTH)
➡︎ Calculates percentage change relative to the previous month
➡︎ Returns blank when the previous month value is blank or zero
➡︎ Inherits the same cohort logic as `Net GMV`

**Scope Notes:**

* This is a growth-rate metric, not an absolute value metric
* It reflects month-over-month change in the dashboard’s cleaned revenue measure
* The measure is highly sensitive to low or unusually volatile prior-month values

---

## gmv-per-customer

- **Display Name:** GMV per Customer
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the average **Net GMV** generated per **valid customer** in the current filter context.

**DAX:**
```DAX
GMV per Customer = 
DIVIDE(
    [Net GMV],
    [Valid Customers]
)
```

**Logic Notes:**

➡︎ Uses `Net GMV` as the numerator
➡︎ Uses `Valid Customers` as the denominator
➡︎ Measures customer-level monetization, not order-level average order value
➡︎ Inherits all cleaning and validity logic from the supporting measures
➡︎ Returns the average amount of cleaned marketplace value generated per distinct valid customer

**Scope Notes:**

* This is a period-sensitive customer value metric
* It responds to the `Reporting Period` and `Customer Region` slicers, year bookmark buttons
* It should be interpreted as **average net revenue per valid customer** in the selected context
* It complements AOV by shifting the lens from order value to customer value

---

# Core Measures - L

## late-delivery-rate-percent-label

- **Display Name:** Late Delivery Rate % Label
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Returns `Late Delivery Rate %` only for a selected set of months so that the combo chart can display a limited number of line labels without cluttering the visual.

**DAX:**
```DAX
Late Delivery Rate % Label =
VAR m = SELECTEDVALUE(dim_date[Month Start])
RETURN
    IF(
        m IN {
            DATE(2017,4,1),
            DATE(2017,9,1),
            DATE(2017,11,1),
            DATE(2018,1,1),
            DATE(2018,3,1),
            DATE(2018,5,1),
            DATE(2018,8,1)
        },
        [Late Delivery Rate %],
        BLANK()
    )
```

**Logic Notes:**

➡︎ Uses `dim_date[Month Start]` to identify the months chosen for labeling
➡︎ Returns `Late Delivery Rate %` only for those selected months
➡︎ Returns BLANK() for all other months so no data label is displayed there
➡︎ Improves readability by keeping the line labeled only at key points rather than at every month

**Scope Notes:**

* This is a presentation-support measure, not a core business KPI, it is used only to control which monthly line values appear as labels
* It does not affect the plotted late-delivery line itself
* It is useful when a full set of labels would overcrowd the chart

---

## late-delivery-rate-percent

- **Display Name:** Late Delivery Rate %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview, Operations Overview

**Business Definition:**  
Calculates the share of **valid delivered orders** that were delivered after the estimated delivery date in the current filter context.

**DAX:**
```DAX
Late Delivery Rate % = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(orders_final[order_id]),
        orders_final[is_late] = TRUE(),
        orders_final[order_status] = "delivered",
        orders_final[timeline_is_valid] = 1,
        orders_final[is_hanging] = 0,
        order_payments_final[payment_value] >= 1
    ),
    [Valid Delivered Orders]
)
```

**Logic Notes:**

➡︎ Counts distinct late `order_id` values in the numerator
➡︎ Uses `orders_final[is_late] = TRUE()` to identify orders delivered after the estimated delivery date
➡︎ Restricts the numerator to delivered orders that pass timeline validity and hanging-order checks
➡︎ Excludes zero-value and micro-value transactions by requiring `payment_value >= 1`
➡︎ Uses `Valid Delivered Orders` as the denominator to express lateness as a share of the cleaned operational cohort

**Scope Notes:**

* This is a period-sensitive delivery-reliability KPI
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It measures deadline failure, not delivery duration
* It is the complement of `On-Time Delivery Rate %`

---

## low-review-percent

- **Display Name:** Low Review %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Represents the share of reviews classified as **low reviews** within the current filter context, where a low review is defined through [`order_review_final[Low Review Flag]`](./olist-dashboard-measures-and-calculated-columns.md#low-review-flag).

**DAX:** 
```DAX
Low Review % = 
DIVIDE(
    SUM(order_review_final[Low Review Flag]),
    COUNTROWS(order_review_final)
)
```

**Logic Notes:**

➡︎ Uses `SUM(order_review_final[Low Review Flag])` as the numerator to count reviews flagged as low  
➡︎ Uses `COUNTROWS(order_review_final)` as the denominator to count all review records in the current filter context  
➡︎ Returns the proportion of reviews that fall into the low-review group rather than the average review score  
➡︎ Is especially useful when comparing dissatisfaction rates across delivery-performance segments such as [`orders_final[Delay Bucket 4]`](./olist-dashboard-measures-and-calculated-columns.md#delay-bucket-4)  
➡︎ Provides a more interpretable dissatisfaction metric than raw low-review counts when the compared groups differ in size  

**Scope Notes:**

* This is a reusable customer-satisfaction measure
* It responds to page filters such as `Customer Region`, `Reporting Period`, and year button selections
* It is evaluated within the current visual and filter context
* Higher values indicate a worse customer experience and a larger concentration of negative reviews
* It is commonly used as an outcome metric in visuals that analyze how delivery performance affects customer dissatisfaction


---

## low-review-flag

- **Display Name:** Low Review Flag
- **Type:** Calculated Column
- **Table:** `order_review_final`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Flags reviews as **low reviews** when the review score is 1 or 2 stars, while preserving blank review scores as `BLANK()` rather than forcing them into a non-low-review category.

**DAX:** 

```DAX
Low Review Flag = 
IF(
    ISBLANK(order_review_final[review_stars]), 
    BLANK(), 
    IF(order_review_final[review_stars] <= 2, 1, 0)
)
```

**Logic Notes:**

➡︎ Uses `order_review_final[review_stars]` as the underlying customer rating field  
➡︎ Returns `BLANK()` when `review_stars` is blank, preventing missing ratings from being misclassified  
➡︎ Returns `1` when the review score is 1 or 2 stars  
➡︎ Returns `0` when the review score is 3, 4, or 5 stars  
➡︎ Converts raw review scores into a binary dissatisfaction indicator for easier aggregation and comparison  
➡︎ Supports percentage-based dissatisfaction metrics by making low reviews countable through simple summation while preserving missing-review integrity  

**Scope Notes:**

* This is a reusable customer-satisfaction classification column
* It is evaluated row by row in `order_review_final`
* It is primarily used as the numerator-building component of [Low Review %](./olist-dashboard-measures-and-calculated-columns.md#low-review-percent)
* It is intended for dissatisfaction analysis rather than full rating-distribution analysis
* It provides a simpler customer-outcome signal than raw star scores when comparing segments such as delivery-delay groups
* Blank review values remain blank and are not treated as valid non-low reviews


---
## lifetime-repeat-customer-rate

- **Display Name:** Lifetime Repeat Customer Rate
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the share of **lifetime valid customers** who placed more than one **valid delivered order** across their full purchase history.

**DAX:**
```DAX
Lifetime Repeat Customer Rate = 
DIVIDE(
    [Lifetime Repeat Customers],
    [Lifetime Valid Customers]
)
```

**Logic Notes:**

➡︎ Uses Lifetime Repeat Customers as the numerator
➡︎ Uses Lifetime Valid Customers as the denominator
➡︎ Measures repeat behavior on a customer lifetime basis, not just within the selected month or period
➡︎ Ignores the date filter because both supporting measures use ALL(dim_date)
➡︎ Retains other page context, such as customer region, unless explicitly removed elsewhere

**Scope Notes:**

* This is a lifetime retention metric, not an in-period repeat rate
* It is not affected by the Reporting Period slicer or year bookmark buttons
* It remains sensitive to non-date filters, such as Customer Region
* It is best interpreted as structural customer retention within the selected segment, rather than short-term repeat activity

---

## lifetime-repeat-customers

- **Display Name:** Lifetime Repeat Customers
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Counts the number of distinct customers who placed **more than one valid delivered order** across their full observed purchase history.

**DAX:**
```DAX
Lifetime Repeat Customers = 
CALCULATE(
    DISTINCTCOUNT(orders_final[customer_unique_id]),
    FILTER(
        ALL(orders_final[customer_unique_id]),
        CALCULATE(
            DISTINCTCOUNT(orders_final[order_id]),
            ALL(dim_date),
            orders_final[order_status] = "delivered",
            orders_final[timeline_is_valid] = 1,
            orders_final[is_hanging] = 0,
            order_payments_final[payment_value] >= 1
        ) > 1
    ),
    ALL(dim_date)
)
```

**Logic Notes:**

➡︎ Counts distinct `customer_unique_id` values, not orders
➡︎ Evaluates each customer across their full available purchase history using ALL(`dim_date`)
➡︎ Classifies a customer as repeat only if they placed more than one valid delivered order
➡︎ Applies the valid-order filters: delivered only, timeline_is_valid = 1, is_hanging = 0, and payment_value >= 1
➡︎ Removes the date filter both when testing repeat behavior and when returning the final count

**Scope Notes:**

* This is a lifetime customer classification measure
* It is not affected by the Reporting Period slicer or year bookmark buttons
* It remains sensitive to non-date filters, such as Customer Region
* It is used as the numerator for `Lifetime Repeat Customer Rate` measure

---

## lifetime-valid-customers

- **Display Name:** Lifetime Valid Customers
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Counts the number of distinct customers who placed at least one **valid delivered order** across the full available dataset.

**DAX:**
```DAX
Lifetime Valid Customers = 
CALCULATE(
    DISTINCTCOUNT(orders_final[customer_unique_id]),
    ALL(dim_date),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Counts distinct `customer_unique_id` values across the full customer history
➡︎ Removes the date filter using ALL(`dim_date`)
➡︎ Includes **only valid delivered orders** (excludes invalid timelines, hanging orders, zero-value transactions, and micro-payments below 1 BRL)
➡︎ Counts each customer once, regardless of how many valid orders they placed

**Scope Notes:**

* This is a lifetime customer-base measure, not a period-specific customer count
* It is not affected by the Reporting Period slicer or year bookmark buttons
* It remains sensitive to non-date filters, such as Customer Region
* It is used as the denominator for `Lifetime Repeat Customer Rate`

---

# Core Measures - N

## net-gmv

* **Display Name:** Net GMV
* **Type:** Measure
* **Table:** _Measures
* **Used in Pages:** Marketplace Overview, ADD

**Business Definition:**
Sums `payment_value` across the dashboard’s valid delivered order cohort to represent the project’s cleaned GMV metric

**DAX:**
```DAX
Net GMV = 
CALCULATE(
    SUM(order_payments_final[payment_value]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Aggregates `payment_value` across **valid delivered orders**
➡︎ Restricts the cohort to `order_status = "delivered"`
➡︎ Excludes timeline-invalid orders via `timeline_is_valid = 1`
➡︎ Excludes hanging orders via `is_hanging = 0`
➡︎ Excludes zero and micro-payments below 1 BRL
➡︎ Uses the same core cohort logic as **Valid Delivered Orders**
➡︎ In this project, `payment_value` is used as the monetary base for GMV calculations

**Scope Notes:**

* This is the dashboard’s main cleaned revenue metric
* It is narrower than **Total Billed**, which sums all billed payment value in context without the same delivery and quality filters
* Because it is based on `payment_value`, it reflects the total billed order amount used in this project’s GMV definition, including freight, rather than item price alone

---

# Core Measures - O

## on-time-delivery-rate-percent

- **Display Name:** On-Time Delivery Rate %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Calculates the share of **valid delivered orders** that were delivered on time in the current filter context.

**DAX:**
```DAX
On-Time Delivery Rate % = 
1 - [Late Delivery Rate %]
```

**Logic Notes:**

➡︎ Uses `Late Delivery Rate %` as the base reliability measure
➡︎ Returns the complement of the late-delivery share
➡︎ Interprets all non-late valid delivered orders as on-time
➡︎ Measures delivery reliability against the estimated delivery promise

**Scope Notes:**

* This is a period-sensitive delivery-reliability KPI
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It should be interpreted as deadline adherence, not physical speed
* It is best analyzed together with `Late Delivery Rate %` and `Average Delivery Time`

---

## orders-final-customer-segment

- **Display Name:** Customer Segment
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Brings the customer frequency segment from the `customer_frequency` table into `orders_final`, so each order inherits the segment of the customer who placed it.

**DAX:**
```DAX
Customer Segment = 
LOOKUPVALUE(
    customer_frequency[Customer Segment],
    customer_frequency[customer_unique_id],
    orders_final[customer_unique_id]
)
```

**Logic Notes:**

➡︎ Uses `customer_unique_id` as the lookup key
➡︎ Maps each order to the segment assigned in `customer_frequency` table
➡︎ Allows customer frequency segmentation to be used directly in order-level visuals and measures
➡︎ Assumes each customer has a single unique segment in the lookup table

**Scope Notes:**

* This is a model-enrichment column, not a dynamic measure
* It is evaluated at refresh time
* It supports order-level reporting by customer purchase segment
* Its correctness depends on the quality and uniqueness of the `customer_frequency` table

---

## orders-mom-percent

- **Display Name:** Orders MoM %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Calculates month-over-month percentage change in `Order Volume`.

**DAX:**
```DAX
Orders MoM % =
VAR CurrentOrders = [Order Volume]
VAR PrevOrders =
    CALCULATE(
        [Order Volume],
        DATEADD('dim_date'[Date], -1, MONTH)
    )
RETURN
DIVIDE(CurrentOrders - PrevOrders, PrevOrders)
```

**Logic Notes:**

➡︎ Uses `Order Volume` for the current month as the numerator base
➡︎ Retrieves the previous month’s `Order Volume` using DATEADD('dim_date'[Date], -1, MONTH)
➡︎ Calculates percentage change relative to the previous month
➡︎ Returns blank when the previous month value is blank or zero
➡︎ Inherits the broader platform scope of `Order Volume`

**Scope Notes:**

* This is a growth-rate metric, not an absolute value metric
* It reflects month-over-month change in broad platform order count
* The measure is highly sensitive to low or unusually volatile prior-month values

---

## order-type

- **Display Name:** Order Type
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Logistics Overview, Operations Overview

**Business Definition:**  
Classifies each order based on delivery status and the number of distinct sellers involved in the order.

**DAX:**
```DAX
Order Type = 
SWITCH(
    TRUE(),
    orders_final[order_status] <> "delivered", "Non-Delivered",
    [Seller Count] = 1, "Single-Seller",
    [Seller Count] > 1, "Multi-Seller"
)
```

**Logic Notes:**

➡︎ Assigns `Non-Delivered` to any order whose status is not "delivered"
➡︎ Assigns `Single-Seller` to delivered orders with exactly one distinct seller
➡︎ Assigns `Multi-Seller` to delivered orders with more than one distinct seller
➡︎ Depends on the supporting measure [`Seller Count`](./olist-dashboard-measures-and-calculated-columns.md#seller-count) to determine seller participation per order

**Scope Notes:**

* This is a model-level classification column evaluated at refresh time
* It is used to compare fulfillment performance by order structure
* On delivered-order pages, the most relevant categories are usually Single-Seller and Multi-Seller
* Non-Delivered may have limited analytical value in visuals that already filter to valid delivered orders

---

## order-volume

- **Display Name:** Order Volume
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Counts distinct orders in the selected filter context.

**DAX:**
```DAX
Order Volume = DISTINCTCOUNT(orders_final[order_id])
```

**Logic Notes:**

➡︎ Counts distinct `order_id`
➡︎ Reflects total order count in the current filter context
➡︎ Does not apply the dashboard’s valid delivered order filters unless those filters are added separately at page, visual, or measure level
➡︎ Serves as a broader marketplace scale metric than **Valid Delivered Orders**

**Scope Notes:**

* This is a broad platform-level order count metric
* It is wider than Valid Delivered Orders, which applies delivery, timeline, hanging-order, and payment-quality filters
* It may include orders outside the dashboard’s core analytical cohort
* When interpreted alongside filtered measures such as **Net GMV**, the difference in cohort logic should be kept in mind

---

## order-processing-time-days

- **Display Name:** Order Processing Time (Days)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview

**Business Definition:**  
Represents the average number of days between order purchase and carrier handoff for orders that qualify as [Valid Delivered Orders](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders).

**DAX:** 
```DAX
Order Processing Time (Days) = 
VAR ValidOrders =
    FILTER(
        orders_final,
        orders_final[order_status] = "delivered"
            && orders_final[timeline_is_valid] = 1
            && orders_final[is_hanging] = 0
            && CALCULATE(
                    SUM(order_payments_final[payment_value]),
                    ALLEXCEPT(order_payments_final, order_payments_final[order_id])
                ) >= 1
    )
RETURN
    AVERAGEX(
        ValidOrders,
        DATEDIFF(
            orders_final[order_purchase_timestamp],
            orders_final[order_delivered_carrier_date],
            DAY
        )
    )
```

**Logic Notes:**

➡︎ Builds a filtered virtual table of orders restricted to the same validity logic used in [Valid Delivered Orders](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders)  
➡︎ Requires delivered status, valid timeline sequencing, non-hanging orders, and order-level payment of at least 1 BRL  
➡︎ Calculates row-level pre-transit duration using `DATEDIFF(order_purchase_timestamp, order_delivered_carrier_date, DAY)`  
➡︎ Averages those row-level durations across the filtered order set using `AVERAGEX`  
➡︎ Captures the time elapsed before the parcel reaches the carrier, including the broader order-to-handoff stage rather than just warehouse handling in a narrow sense  

**Scope Notes:**

* This is a reusable logistics stage-duration measure
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It is best interpreted together with [Transit Time (Days)](./olist-dashboard-measures-and-calculated-columns.md#transit-time-days) and [Avg Delivery Time (Days)](./olist-dashboard-measures-and-calculated-columns.md#avg-delivery-time-days)
* Higher values indicate slower pre-shipment execution before the delivery network takes over
* It helps distinguish seller/platform-side delay from transport-stage delay in regional logistics comparisons

---

# Core Measures - P

## percent-revenue-at-risk

- **Display Name:** % Revenue at Risk
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Calculates the share of [Net GMV](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) in the current filter context that is associated with dissatisfied orders, where dissatisfied orders are defined as reviews with `review_stars <= 2`.

**DAX:**
```DAX
% Revenue at Risk = 
DIVIDE(
    [Revenue at Risk],
    [Net GMV]
)
```

**Logic Notes:**

➡︎ Uses [`Revenue at Risk`](./olist-dashboard-measures-and-calculated-columns.md#revenue-at-risk) as the numerator  
➡︎ Uses [`Net GMV`](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) as the denominator  
➡︎ Returns the proportional share of billed value tied to low-rated orders within the current filter context  
➡︎ Complements the absolute-value measure by showing concentration rather than scale  
➡︎ Makes it possible to compare commercial-risk intensity across delay categories even when their total GMV differs materially  

**Scope Notes:**

* This is a reusable commercial-risk ratio measure
* It responds to page filters such as `Customer Region`, `Reporting Period`, year button selections, and delay-category grouping
* It is evaluated within the current filter context
* Higher values indicate that a larger share of category GMV is exposed to dissatisfied-order outcomes
* It is best interpreted together with [Revenue at Risk](./olist-dashboard-measures-and-calculated-columns.md#revenue-at-risk) because a small category can have a high risk share but low absolute value

---

# Core Measures- R

## revenue-at-risk

- **Display Name:** Revenue at Risk
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Calculates the amount of [Net GMV](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) associated with dissatisfied orders in the current filter context, where dissatisfaction is defined as reviews with `review_stars <= 2`.

**DAX:**
```DAX
Revenue at Risk = 
CALCULATE(
    [Net GMV],
    KEEPFILTERS(order_review_final[review_stars] <= 2)
)
```

**Logic Notes:**

➡︎ Uses [Net GMV](./olist-dashboard-measures-and-calculated-columns.md#net-gmv) as the commercial value base  
➡︎ Applies `KEEPFILTERS(order_review_final[review_stars] <= 2)` to restrict the measure to low-rated orders only  
➡︎ Preserves existing visual and page context while narrowing the result to dissatisfied-order revenue  
➡︎ Returns the billed value exposed to poor customer outcomes rather than total GMV  
➡︎ Connects customer satisfaction analysis to direct commercial impact by quantifying how much revenue sits inside low-review orders  

**Scope Notes:**

* This is a reusable commercial-risk measure
* It responds to page filters such as `Customer Region`, `Reporting Period`, year button selections, and delay-category grouping
* It is evaluated within the current filter context and inherits the cohort logic of [Net GMV](./olist-dashboard-measures-and-calculated-columns.md#net-gmv)
* Higher values indicate a larger absolute amount of revenue associated with dissatisfied orders
* It is best interpreted together with [% Revenue at Risk](./olist-dashboard-measures-and-calculated-columns.md#percent-revenue-at-risk) to distinguish scale from concentration

---

## revenue-from-repeat-customers-percent

- **Display Name:** Revenue from Repeat Customers %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the share of total **Net GMV** contributed by customers classified as repeat buyers in the current filter context.

**DAX:**
```DAX
Revenue from Repeat Customers % = 
DIVIDE(
    [Repeat Customer GMV],
    [Net GMV]
)
```

**Logic Notes:**

➡︎ Uses [`Repeat Customer GMV`](./olist-dashboard-measures-and-calculated-columns.md#repeat-customer-gmv) as the numerator
➡︎ Uses total `Net GMV` as the denominator
➡︎ Measures how much of cleaned marketplace revenue comes from repeat-customer segments rather than one-time buyers
➡︎ Returns a proportion of total `Net GMV` attributable to repeat customers

**Scope Notes:**

* This is a revenue-mix metric rather than a customer-count metric
* It responds to slicers and page filters, subject to the behavior of the customer segmentation model
* It complements repeat-rate KPIs by showing the value contribution of retained customers
* Interpretation depends on how customer segments are defined in the [`customer_frequency`](./olist-dashboard-measures-and-calculated-columns.md#customer-frequency-table) table
---

## repeat-customer-gmv

- **Display Name:** Repeat Customer GMV
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the **Net GMV** generated by customers classified as repeat buyers, excluding those labeled as one-time buyers.

**DAX:**
```DAX
Repeat Customer GMV = 
CALCULATE(
    [Net GMV],
    customer_frequency[Customer Segment] <> "One-time buyers"
)
```

**Logic Notes:**

➡︎ Starts from `Net GMV` as the base revenue measure
➡︎ Excludes customers in the One-time buyers segment
➡︎ Includes revenue from **Light repeat** buyers and **Heavy repeat** buyers
➡︎ Depends on the customer segmentation table correctly filtering the revenue context

**Scope Notes:**

* This is a segment-filtered revenue metric
* It is used as the numerator for `Revenue from Repeat Customers %`
* It is sensitive to page filters and to the model relationship between customer_frequency and the fact tables
* Its interpretation depends on whether customer segments are defined from all orders or only a cleaned valid-order cohort

---

## returning-customers

- **Display Name:** Returning Customers
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Counts the number of distinct customers in the current month who qualify as valid customers and whose earliest recorded purchase occurred before the current month.

**DAX:**
```DAX
Returning Customers = 
CALCULATE(
    DISTINCTCOUNT(orders_final[customer_unique_id]),
    FILTER(
        VALUES(orders_final[customer_unique_id]),
        CALCULATE(
            MIN(orders_final[order_purchase_timestamp]),
            ALL(dim_date)
        ) < MIN(dim_date[Date])
    ),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Counts distinct `customer_unique_id` values in the current month context
➡︎ Tests whether each customer’s earliest recorded purchase date is earlier than the current month being evaluated
➡︎ Removes the date filter inside the earliest-purchase check using ALL(dim_date) so purchase history is assessed across the full dataset
➡︎ Applies the valid-order filters: `delivered only, timeline_is_valid = 1, is_hanging = 0, and payment_value >= 1`
➡︎ Returns customers, who are active in the current month and have prior purchase history

**Scope Notes:**

* This is a dynamic monthly retention measure
* It is sensitive to the current month on the axis and to page filters
* It is used as the numerator for `Returning Customer Rate`
* It should be interpreted as monthly returning-customer participation, **not lifetime repeat-customer count**

---

## returning-customer-rate

- **Display Name:** Returning Customer Rate
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the share of monthly valid customers who had already made at least one purchase before the current month.

**DAX:**
```DAX
Returning Customer Rate = 
DIVIDE(
    [Returning Customers],
    [Valid Customers]
)
```

**Logic Notes:**

➡︎ Uses [`Returning Customers`](./olist-dashboard-measures-and-calculated-columns.md#returning-customers) as the numerator
➡︎ Uses [`Valid Customers`](./olist-dashboard-measures-and-calculated-columns.md#valid-customers) as the denominator
➡︎ Measures the proportion of active monthly customers who are returning rather than first-time
➡︎ Inherits the cleaned valid-order logic from both supporting measures

**Scope Notes:**

* This is a period-sensitive retention trend metric
* It responds to page filters, but in this visual no additional visual-level filters are applied
* It should be interpreted month by month within the displayed timeline
* It is distinct from [`Lifetime Repeat Customer Rate`](./olist-dashboard-measures-and-calculated-columns.md#lifetime-repeat-customer-rate), which is a lifetime classification metric, rather than a monthly returning-share metric

---

## returning-customer-rate-label

- **Display Name:** Returning Customer Rate Label
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Returns `Returning Customer Rate` only for selected months so that data labels can be shown selectively on the line chart without overcrowding the visual.

**DAX:**
```DAX
Returning Customer Rate Label = 
VAR m = SELECTEDVALUE(dim_date[Month Start])
RETURN
    SWITCH(
        TRUE(),
        m IN {
            DATE(2017,1,1),
            DATE(2017,4,1), 
            DATE(2017,6,1),
            DATE(2017,9,1),
            DATE(2018,2,1),
            DATE(2018,4,1),
            DATE(2018,6,1), 
            DATE(2018,8,1)
        },
        [Returning Customer Rate],
        BLANK()
    )
```

**Logic Notes:**

➡︎ Uses `dim_date[YearMonth]` rather than the display label text to identify target months
➡︎ Returns the actual Returning Customer Rate only for a curated set of important months
➡︎ Returns BLANK() for all other months so no label is displayed there
➡︎ Improves readability without changing the underlying trend line

**Scope Notes:**

* This is a presentation-support measure, not a core business KPI
* It is used only to control data label placement on the line chart and it does not affect the plotted line itself

---

## review-percent

- **Display Name:** Review %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Represents the share of reviews in the current review-score bucket relative to the total number of reviews in the comparison set.

**DAX:**
```DAX
Review % = 
DIVIDE(
    COUNT(order_review_final[review_id]),
    CALCULATE(COUNT(order_review_final[review_id]), ALL(order_review_final))
)
```

**Logic Notes:**

➡︎ Uses `COUNT(order_review_final[review_id])` as the numerator to count reviews in the current filter context  
➡︎ Uses `CALCULATE(COUNT(order_review_final[review_id]), ALL(order_review_final))` as the denominator to compare each bucket against the full review table  
➡︎ Returns the proportional share of total reviews represented by the current category  
➡︎ Is used as a displayed-value label in the review score distribution chart rather than as the primary y-axis measure  
➡︎ Works as a distribution-reading aid by translating raw review counts into percentage share  

**Scope Notes:**

* This is a reusable review-distribution measure
* It is evaluated within the current visual context
* It is currently used to display percentage labels in the Review Score Distribution chart
* Because it uses `ALL(order_review_final)`, it should be interpreted carefully when page filters or slicers are applied
* It is best read alongside the underlying review count axis rather than as a standalone satisfaction metric

---


# Core Measures - S

## seller-eligible-for-ranking

- **Display Name:** Seller Eligible for Ranking
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Returns the number of eligible single-seller orders with calculable approval-to-carrier time for the seller currently in context, and is used as the minimum-volume filter for seller ranking.

**DAX:**
```DAX
Seller Eligible for Ranking = 
[Single-Seller Orders with Approval-To-Carrier]
```

**Logic Notes:**

➡︎ Reuses `Single-Seller Orders with Approval-To-Carrier` as the seller eligibility metric
➡︎ Counts the seller’s comparable order base for approval-to-carrier analysis
➡︎ Is used as a ranking guardrail, rather than as a standalone business KPI
➡︎ Helps reduce volatility caused by very small seller samples

**Scope Notes:**

* This is a supporting filter measure and is used as a visual-level threshold in the seller ranking chart
* In the current setup, sellers must have at least 30 eligible orders to appear
* It improves comparability and reduces small-sample distortion in seller rankings

---

## seller-label-short

- **Display Name:** Seller Label Short
- **Type:** Calculated Column
- **Table:** `sellers_final`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Creates a shortened seller identifier for display purposes in visuals where the full seller ID would be too long to read comfortably.

**DAX:**
```DAX
Seller Label Short = 
LEFT(sellers_final[seller_id], 8) & "..."
```

**Logic Notes:**

➡︎ Takes the first 8 characters of `seller_id` and appends "..." to indicate truncation
➡︎ Improves chart readability without changing seller-level granularity
➡︎ Is intended only for display, not for analytical grouping logic

**Scope Notes:**

* This is a presentation-support column
* It is evaluated at model refresh
* It is used to keep seller labels readable in ranked visuals
* It should be interpreted only as a shortened alias of the underlying seller identifier

---

## slow-processing-rate-percent-p90

- **Display Name:** Slow Processing Rate % (P90)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Calculates the share of eligible orders whose **approval-to-carrier time** exceeds the platform-wide **90th percentile** threshold.

**DAX:**
```DAX
Slow Processing Rate % (P90) = 
DIVIDE(
    [Slow Processed Orders (P90)],
    [Single-Seller Orders with Approval-To-Carrier]
)
```

**Logic Notes:**

➡︎ Uses `Slow Processed Orders (P90)` as the numerator
➡︎ Uses `Single-Seller Orders with Approval-To-Carrier` as the denominator
➡︎ Measures the frequency of extreme seller-side processing delays rather than average processing time
➡︎ Because the underlying approval-to-carrier field is only populated for valid single-seller orders, the measure is effectively restricted to that cohort

**Scope Notes:**

* This is a seller-level operational risk metric
* It is used to rank sellers by frequency of severe internal processing delay
* It should be interpreted as a relative extremity measure, not as average duration
* It is especially useful for identifying chronic processing outliers

---

## single-seller-orders-with-approval-to-carrier

- **Display Name:** Single-Seller Orders with Approval-To-Carrier
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Counts the number of delivered single-seller orders with a non-blank approval-to-carrier duration in the current filter context.

**DAX:**
```DAX
Single-Seller Orders with Approval-To-Carrier = 
CALCULATE(
    DISTINCTCOUNT(orders_final[order_id]),
    FILTER(
        orders_final,
        NOT ISBLANK(orders_final[Approval To Carrier (Days Decimal)])
    )
)
```

**Logic Notes:**

➡︎ Counts distinct order_id values
➡︎ Includes only orders where Approval To Carrier (Days Decimal) is not blank
➡︎ Because that calculated column only returns values for timeline_is_valid = 1, Single-Seller orders with both timestamps present, the measure inherits that logic indirectly
➡︎ Provides the eligible order base for seller-level extreme-delay calculations

**Scope Notes:**

* This is an eligibility-denominator measure
* It is used as the denominator for Slow Processing Rate % (P90)
* It reflects only orders where pre-shipment processing time can be meaningfully calculated
* It should be interpreted as the seller's comparable processing-order base

---

## slow-processed-orders-p90

- **Display Name:** Slow Processed Orders (P90)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Counts the number of eligible orders whose **approval-to-carrier time** exceeds the platform-wide **90th percentile** threshold in the current filter context.

**DAX:**
```DAX
Slow Processed Orders (P90) = 
VAR P90Threshold = [Approval To Carrier P90]
RETURN
CALCULATE(
    DISTINCTCOUNT(orders_final[order_id]),
    FILTER(
        orders_final,
        NOT ISBLANK(orders_final[Approval To Carrier (Days Decimal)]) &&
        orders_final[Approval To Carrier (Days Decimal)] > P90Threshold
    )
)
```

**Logic Notes:**

➡︎ Retrieves the platform-wide P90 threshold through [Approval To Carrier P90]
➡︎ Counts distinct order_id values whose approval-to-carrier duration exceeds that threshold
➡︎ Restricts to orders where Approval To Carrier (Days Decimal) is not blank
➡︎ Identifies severe seller-side processing delays rather than average performance

**Scope Notes:**

* This is the numerator for Slow Processing Rate % (P90)
* It is sensitive to the P90 benchmark used in the model
* It should be interpreted as a count of extreme processing-delay cases
* It is most useful when paired with a minimum-volume filter to avoid small-sample distortion

---

## selected-seller-id

- **Display Name:** Selected Seller ID
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Operations Overview

**Business Definition:**  
Returns the full seller ID for the seller currently in context, so the tooltip can show the complete identifier behind the shortened display label.

**DAX:**
```DAX
Selected Seller ID = 
SELECTEDVALUE(sellers_final[seller_id])
```

**Logic Notes:**

➡︎ Uses SELECTEDVALUE to return the current seller’s full seller_id
➡︎ Supports tooltip readability when the axis uses a shortened seller label
➡︎ Returns a single seller identifier only when one seller is in filter context

**Scope Notes:**

* This is a presentation-support measure
* It is used in tooltips rather than as an analytical KPI
* It helps preserve readability without losing seller traceability
* It depends on seller-level context being present in the visual

---

## severely-late-3d-percent

- **Display Name:** Severely Late (>3d) %
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview

**Business Definition:**  
Represents the percentage of [Valid Delivered Orders](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders) that were delivered more than three days later than the estimated delivery date.

**DAX:**
```DAX
Severely Late (>3d) % = 
DIVIDE(
    CALCULATE(
        [Valid Delivered Orders],
        orders_final[Delay Category] = "Severely Late (>3d)"
    ),
    [Valid Delivered Orders]
)
```

**Logic Notes:**

➡︎ Uses `Valid Delivered Orders` as both the filtered numerator base and the denominator
➡︎ Filters the numerator to orders classified as Severely Late (>3d) in `orders_final[Delay Category]`
➡︎ Measures the share of the valid delivered order cohort affected by the most serious delivery delays
➡︎ More selective than `Late Delivery Rate %` because it excludes mildly late orders
➡︎ Useful for distinguishing general lateness from severe service failures with higher customer-impact risk

**Scope Notes:**

* This is a reusable logistics reliability measure
* It responds to page filters such as Reporting Period, Customer Region, and Order Type
* It is evaluated within the current filter context
* Higher values indicate a larger concentration of materially late deliveries
* It is best interpreted alongside `On-Time Delivery Rate %` and `Late Delivery Rate %`

---

## seller-count

- **Display Name:** Seller Count
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Logistics Overview, Operations Overview

**Business Definition:**  
Counts the number of distinct sellers associated with an order.

**DAX:**
```DAX
Seller Count = 
CALCULATE(
    DISTINCTCOUNT(order_items_final[seller_id]),
    FILTER(
        order_items_final,
        order_items_final[order_id] = orders_final[order_id]
    ),
    orders_final[order_status] = "delivered"
)
```

**Logic Notes:**

➡︎ Counts distinct seller_id values in order_items_final for the current order
➡︎ Matches order items to the current order using order_id
➡︎ Restricts the count to delivered orders
➡︎ Returns the number of sellers participating in each delivered order

**Scope Notes:**

* This measure is primarily used to support the Order Type calculated column
* It is evaluated in the row context of orders_final when used inside that column
* It helps distinguish simpler single-seller fulfillment from more complex multi-seller fulfillment
* Its output is meaningful only at order level

---

## shopping-period

- **Display Name:** Shopping Period
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Assigns each order to a business-defined commercial period based on its purchase date. It is used to compare whether customer dissatisfaction and delay sensitivity differ across major holiday and campaign windows versus regular periods.

**DAX:**

```DAX
Shopping Period = 
VAR d = orders_final[order_purchase_date]
RETURN
    SWITCH(
        TRUE(),
        d >= DATE(2016,12,4) && d <= DATE(2016,12,30), "Christmas",
        d >= DATE(2017,12,4) && d <= DATE(2017,12,30), "Christmas",

        d >= DATE(2017,5,7) && d <= DATE(2017,5,17), "Mothers Day",
        d >= DATE(2018,5,6) && d <= DATE(2018,5,16), "Mothers Day",

        d >= DATE(2017,8,6) && d <= DATE(2017,8,16), "Fathers Day",
        d >= DATE(2018,8,5) && d <= DATE(2018,8,15), "Fathers Day",

        d >= DATE(2017,6,5) && d <= DATE(2017,6,14), "Valentines Day",
        d >= DATE(2018,6,5) && d <= DATE(2018,6,14), "Valentines Day",

        d >= DATE(2016,10,5) && d <= DATE(2016,10,14), "Childrens Day",
        d >= DATE(2017,10,5) && d <= DATE(2017,10,15), "Childrens Day",

        d >= DATE(2016,11,1) && d <= DATE(2016,11,30), "Black November",
        d >= DATE(2017,11,1) && d <= DATE(2017,11,30), "Black November",

        d >= DATE(2017,3,12) && d <= DATE(2017,3,17), "Dia do Consumidor",
        d >= DATE(2018,3,12) && d <= DATE(2018,3,17), "Dia do Consumidor",

        d >= DATE(2017,2,24) && d <= DATE(2017,3,3), "Carnival",
        d >= DATE(2018,2,9) && d <= DATE(2018,2,16), "Carnival",

        "Regular"
    )
```

**Logic Notes:**

➡︎ Uses `orders_final[order_purchase_date]` as the underlying timing field  
➡︎ Maps specific date windows in 2016–2018 to named commercial periods such as `Christmas`, `Black November`, `Carnival`, etc.  
➡︎ Assigns orders outside those campaign windows to `Regular`  
➡︎ Creates a business-facing seasonal grouping layer for customer-experience analysis  
➡︎ Makes it possible to compare whether poor delivery performance produces different dissatisfaction outcomes during different shopping periods  

**Scope Notes:**

* This is a reusable behavioral-grouping column
* It is evaluated row by row in `orders_final`
* It is intended for grouped analysis rather than direct KPI calculation
* It is especially useful in the holiday-sensitivity heatmap and related customer-experience visuals

---

## shopping-period-hm-sort

- **Display Name:** Shopping Period HM Sort
- **Type:** Calculated Column
- **Table:** `orders_final`
- **Used in Pages:** Customer Experience

**Business Definition:**  
Provides a fixed sort order for [`orders_final[Shopping Period]`](./olist-dashboard-measures-and-calculated-columns.md#shopping-period) so shopping periods appear in a deliberate analytical sequence in the heatmap rather than alphabetically.

**DAX:** 

```DAX
Shopping Period HM Sort = 
SWITCH(
    orders_final[Shopping Period],
    "Childrens Day", 1,
    "Christmas", 2,
    "Carnival", 3,
    "Black November", 4,
    "Valentines Day", 5,
    "Dia do Consumidor", 6,
    "Regular", 7,
    "Mothers Day", 8,
    "Fathers Day", 9,
    99
)
```

**Logic Notes:**

➡︎ Uses [`orders_final[Shopping Period]`](./olist-dashboard-measures-and-calculated-columns.md#shopping-period) as the source grouping field  
➡︎ Assigns a numeric sequence to each shopping period so visuals follow an intentional business order  
➡︎ Prevents Power BI from defaulting to alphabetical sorting, which would weaken interpretability  
➡︎ Uses `99` as a fallback for unexpected or unmatched values  
➡︎ Supports cleaner comparison across shopping periods in matrix and heatmap visuals where row order matters  

**Scope Notes:**

* This is a reporting-support sort column
* It is evaluated row by row in `orders_final`
* It is not a business metric by itself
* It is intended to improve readability and narrative flow in shopping-period visuals
* It complements reporting dimensions such as `dim_shopping_period` when stable sort behavior is needed

---

# Core Measures - T

## top-10-percent-customers-gmv-share

- **Display Name:** Top 10% Customers GMV Share
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the share of total `Net GMV` contributed by the top 10% of customers ranked by cleaned customer-level `Net GMV` in the current filter context.

**DAX:**
```DAX
Top 10% Customers GMV Share =
VAR CustomerTable =
    FILTER(
        ADDCOLUMNS(
            VALUES(orders_final[customer_unique_id]),
            "@CustomerGMV", [Net GMV]
        ),
        NOT ISBLANK([@CustomerGMV]) && [@CustomerGMV] > 0
    )
VAR CustomerCount =
    COUNTROWS(CustomerTable)
VAR TopCustomerCount =
    MAX(1, ROUNDUP(CustomerCount * 0.10, 0))
VAR TopCustomers =
    TOPN(
        TopCustomerCount,
        CustomerTable,
        [@CustomerGMV], DESC
    )
VAR TopCustomersGMV =
    SUMX(TopCustomers, [@CustomerGMV])
VAR TotalGMV =
    [Net GMV]
RETURN
    DIVIDE(TopCustomersGMV, TotalGMV)
```

**Logic Notes:**

**Logic Notes:**

➡︎ Builds a virtual customer table from distinct `customer_unique_id` values in the current filter context
➡︎ Adds customer-level `Net GMV` to each customer row using `[@CustomerGMV]`
➡︎ Keeps only customers with positive cleaned `Net GMV` by excluding blank and zero-value rows
➡︎ Calculates the top 10% cohort size using ROUNDUP, so fractional customers are rounded upward
➡︎ Uses `TOPN` to select the highest-value customers by cleaned `Net GMV`
➡︎ Sums `Net GMV` across that top customer cohort and divides it by total `Net GMV` in the same context

**Scope Notes:**

* This is a customer-value concentration metric
* It is fully sensitive to slicers and page filters, including Customer Region and Reporting Period
* It should be interpreted as the degree to which revenue is concentrated among the highest-value valid customers
* In small filtered populations, the top cohort may contain very few customers because the measure always rounds up to at least 1 customer

---

## top-10-percent-customer-count

- **Display Name:** Top 10% Customer Count
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Calculates the number of customers included in the top 10% customer cohort, based only on customers with positive cleaned `Net GMV` in the current filter context.

**DAX:**
```DAX
Top 10% Customer Count =
VAR CustomerTable =
    FILTER(
        ADDCOLUMNS(
            VALUES(orders_final[customer_unique_id]),
            "@CustomerGMV", [Net GMV]
        ),
        NOT ISBLANK([@CustomerGMV]) && [@CustomerGMV] > 0
    )
VAR CustomerCount =
    COUNTROWS(CustomerTable)
RETURN
    MAX(1, ROUNDUP(CustomerCount * 0.10, 0))
```

**Logic Notes:**

➡︎ Builds a virtual customer table from distinct `customer_unique_id` values in the current filter context
➡︎ Adds customer-level `Net GMV` to each customer row using `[@CustomerGMV]`
➡︎ Keeps only customers with positive cleaned `Net GMV` by excluding blank and zero-value rows
➡︎ Counts the resulting customer base and multiplies it by 10%
➡︎ Uses `ROUNDUP` so the cohort size is always rounded upward to a whole customer
➡︎ Uses MAX(1, …) to guarantee that at least one customer is included

**Scope Notes:**

* This is a helper concentration metric used to contextualize `Top 10% Customers GMV Share`
* It is fully sensitive to slicers and page filters
* It should be interpreted as the size of the high-value customer cohort in the selected context
* In very small filtered views, the measure can overstate the notion of "10%" because it never returns zero

---

## total-billed

- **Display Name:** Total Billed
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Sums total customer payment value in the selected context. In the Olist dataset, `payment_value` reflects the billed order amount and generally includes freight.

**DAX:**
```DAX
Total Billed = SUM(order_payments_final[payment_value])
```

**Logic Notes:**

➡︎ Aggregates all values in `order_payments_final[payment_value]`
➡︎ Reflects customer billed amount rather than merchandise-only value
➡︎ Includes freight charged to the customer
➡︎ Does not apply the dashboard’s valid delivered order filters unless added explicitly

**Scope Notes:**

* This is a broad platform-level billing metric
* It is wider than Net GMV, which applies delivery, timeline, hanging-order, and payment-quality filters
* It can include orders outside the dashboard’s core valid-order cohort

---

## total-customers

- **Display Name:** Total Customers
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Counts distinct customers in the selected filter context, providing a broad view of marketplace customer reach.

**DAX:**
```DAX
Total Customers =
DISTINCTCOUNT(customers_final[customer_unique_id])
```

**Logic Notes:**

➡︎ Counts distinct **customer_unique_id**
➡︎ Reflects total customers in the current filter context
➡︎ Does not apply the dashboard’s valid delivered order filters, unless those filters are added separately at page, visual, or report level
➡︎ Serves as a broad marketplace size metric, rather than a cleaned analytical cohort metric

**Scope Notes:**

* This is a broad platform-level customer count metric
* It is wider than **Customers with Valid Orders**, which is restricted to the dashboard’s core valid-order cohort
* Because it is calculated from `customers_final`, it reflects customer records in the selected context, rather than only customers tied to **valid delivered orders**
* When interpreted alongside filtered measures such as **Net GMV** or **Valid Delivered Orders**, the difference in cohort logic should be kept in mind

---

## total-sellers

- **Display Name:** Total Sellers
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Marketplace Overview

**Business Definition:**  
Counts distinct sellers in the selected filter context, providing a broad view of marketplace seller base size.

**DAX:**
```DAX
Total Sellers =
DISTINCTCOUNT(sellers_final[seller_id])
```

**Logic Notes:**

➡︎ Counts distinct `seller_id`
➡︎ Reflects total sellers in the current filter context
➡︎ Does not require seller transactional activity, unless that activity is imposed through page, visual, or model filter context
➡︎ Serves as a broad marketplace supply-side size metric

**Scope Notes:**

* This is a broad platform-level seller count metric
* It reflects seller records in context, rather than only sellers with confirmed order activity

---

## transit-time-days

- **Display Name:** Transit Time (Days)
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview

**Business Definition:**  
Represents the average number of days between carrier handoff and final customer delivery for orders that qualify as [Valid Delivered Orders](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders).

**DAX:** 
```DAX
Transit Time (Days) = 
VAR ValidOrders =
    FILTER(
        orders_final,
        orders_final[order_status] = "delivered"
            && orders_final[timeline_is_valid] = 1
            && orders_final[is_hanging] = 0
            && CALCULATE(
                    SUM(order_payments_final[payment_value]),
                    ALLEXCEPT(order_payments_final, order_payments_final[order_id])
                ) >= 1
    )
RETURN
    AVERAGEX(
        ValidOrders,
        DATEDIFF(
            orders_final[order_delivered_carrier_date],
            orders_final[order_delivered_customer_date],
            DAY
        )
    )
```

**Logic Notes:**

➡︎ Builds a filtered virtual table of orders restricted to the same validity logic used in [Valid Delivered Orders](./olist-dashboard-measures-and-calculated-columns.md#valid-delivered-orders)  
➡︎ Requires delivered status, valid timeline sequencing, non-hanging orders, and order-level payment of at least 1 BRL  
➡︎ Calculates row-level transit duration using `DATEDIFF(order_delivered_carrier_date, order_delivered_customer_date, DAY)`  
➡︎ Averages those row-level durations across the filtered order set using `AVERAGEX`  
➡︎ Measures only the carrier-to-customer transport stage rather than the full purchase-to-delivery journey  

**Scope Notes:**

* This is a reusable logistics stage-duration measure
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It is best interpreted together with [Order Processing Time (Days)](./olist-dashboard-measures-and-calculated-columns.md#order-processing-time-days) and [Avg Delivery Time (Days)](./olist-dashboard-measures-and-calculated-columns.md#avg-delivery-time-days)
* Higher values indicate slower downstream transport performance after the order has already reached the carrier
* It is especially useful for separating network or geography-driven delay from earlier seller/platform processing stages

---

# Core Measures - V

## valid-customers

- **Display Name:** Customers with Valid Orders
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Customer Behavior Overview

**Business Definition:**  
Counts the number of distinct customers who placed at least one **valid delivered order** in the current filter context.

**DAX:**
```DAX
Valid Customers = 
CALCULATE(
    DISTINCTCOUNT(orders_final[customer_unique_id]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Counts distinct `customer_unique_id` values rather than orders
➡︎ Includes only orders with `order_status` = "delivered"
➡︎ Excludes records where `timeline_is_valid` = 1
➡︎ Excludes records where `is_hanging` = 1
➡︎ Excludes zero-value and micro-value transactions by requiring `payment_value` >= 1
➡︎ Ensures each customer is counted once, even if they placed multiple valid orders

**Scope Notes:**

* This is a cleaned customer-base metric, not a raw customer count
* It is fully sensitive to slicers and page filters
* It is used as the denominator or reference population for multiple customer behavior KPIs
* It should be interpreted as the number of commercially relevant customers in the selected context

---

## valid-delivered-orders

* **Display Name:** Valid Delivered Orders
* **Type:** Measure
* **Table:** _Measures
* **Used in Pages:** Marketplace Overview, Operations, Customer Behavior, Logistics, 

**Business Definition:**
Counts distinct orders that belong to the dashboard’s core valid order cohort.

**DAX:**
```DAX
Valid Delivered Orders =
CALCULATE(
    DISTINCTCOUNT(orders_final[order_id]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```

**Logic Notes:**

➡︎ Counts distinct order_id
➡︎ Restricts the cohort to delivered orders only
➡︎ Excludes timeline-invalid orders
➡︎ Excludes hanging orders
➡︎ Excludes zero and micro-payment orders below 1 BRL

**Scope Notes:**

* This measure defines the dashboard’s core valid-order cohort
* It is used as the main order baseline for cleaned analytical metrics across multiple report pages
* Compared with broader platform metrics, it focuses only on delivered orders that pass the project’s data-quality and payment filters

---

# Core Measures - W

## worst-region-late-rate

- **Display Name:** Worst Region Late Rate
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview

**Business Definition:**  
Returns the name of the customer region with the highest [`Late Delivery Rate %`](./olist-dashboard-measures-and-calculated-columns.md#late-delivery-rate-) within the current filter context.

**DAX:** `Worst Region Late Rate`
```DAX
Worst Region Late Rate = 
MAXX(
    TOPN(
        1,
        VALUES(customers_final[Customer Region]),
        [Late Delivery Rate %],
        DESC
    ),
    customers_final[Customer Region]
)
```

**Logic Notes:**

➡︎ Evaluates [`Late Delivery Rate %`](./olist-dashboard-measures-and-calculated-columns.md#late-delivery-rate-) across the visible values of `customers_final[Customer Region]`  
➡︎ Uses `TOPN(1, ...)` to identify the region with the highest late delivery rate  
➡︎ Uses `MAXX(...)` to return the corresponding region label as text  
➡︎ Does not apply additional internal filters beyond the current filter context  
➡︎ Returns the worst-performing customer region from a delivery reliability perspective  

**Scope Notes:**

* This is a reusable text-returning ranking measure
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It is intended for KPI card use rather than numeric aggregation
* It is best interpreted alongside [`Late Delivery Rate %`](./olist-dashboard-measures-and-calculated-columns.md#late-delivery-rate-) and regional delivery visuals
* If multiple regions are tied, the returned result depends on how `TOPN` resolves the tie within the current context

---

## worst-region-avg-delivery

- **Display Name:** Worst Region Avg Delivery
- **Type:** Measure
- **Table:** `_Measures`
- **Used in Pages:** Logistics Overview

**Business Definition:**  
Returns the name of the customer region with the highest [Avg Delivery Time (Days)](./olist-dashboard-measures-and-calculated-columns.md#avg-delivery-time-days) within the current filter context.

**DAX:** 
```DAX
Worst Region Avg Delivery = 
TOPN(
    1,
    VALUES(customers_final[Customer Region]),
    [Avg Delivery Time (Days)],
    DESC
)
```

**Logic Notes:**

➡︎ Evaluates [`Avg Delivery Time (Days)`](./olist-dashboard-measures-and-calculated-columns.md#avg-delivery-time-days) across the visible values of `customers_final[Customer Region]`  
➡︎ Uses `TOPN(1, ...)` to identify the region with the highest average delivery time  
➡︎ Returns the slowest-performing customer region from a delivery-speed perspective  
➡︎ Does not apply additional internal filters beyond the current filter context  
➡︎ Is intended to surface the worst regional delivery-speed outcome in a compact text KPI  

**Scope Notes:**

* This is a reusable text-returning ranking measure
* It responds to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`
* It is intended for KPI card use rather than numeric aggregation
* It is best interpreted alongside [`Avg Delivery Time (Days)`](./olist-dashboard-measures-and-calculated-columns.md#avg-delivery-time-days) and regional delivery visuals
* If multiple regions are tied, the returned result depends on how `TOPN` resolves the tie within the current context

---