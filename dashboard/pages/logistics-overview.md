# Olist Dashboard — Logistics Overview

**Business Context:** *Core Question: Where are the logistics bottlenecks, and how much does delivery performance vary by geography?*  
This page provides a high-level view of logistics performance across the marketplace. It focuses on delivery speed, delivery reliability, and regional differences in customer experience, helping identify where fulfillment performance weakens and how strongly logistics outcomes vary across customer regions.

## 1. Report page purpose

- **Page Role:** Logistics performance overview  
- **Primary Objective:** Assess delivery speed and reliability across the marketplace and highlight geographic differences in delivery performance  
- **Grain of Analysis:** Primarily order-level, with customer-region aggregation for comparative delivery performance  

**Key Business Questions:**

- How long does delivery take on average across the marketplace?
- What share of valid delivered orders arrive after the estimated delivery date?
- Which customer regions experience the slowest delivery times?
- Which customer regions face the highest late delivery rates?
- How different is the delivery experience across regions?
- Do single-seller and multi-seller orders show different logistics performance patterns?

---

## 2. Page-level filters and navigation controls

This page includes three dropdown slicers that control the reporting window, customer geography, and fulfillment structure being analyzed. These controls are designed to let the viewer move between broad logistics patterns and narrower operational slices without changing the logic of the page.

### 2.1 Reporting Period slicer

- **Field used:** `dim_date[YearMonth Label]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to one or multiple selected reporting months
- **Behavior:** Supports single-month and multi-month selection, allowing the viewer to assess logistics performance over a custom time window rather than across the full dataset

**Business use:**  
This slicer allows the viewer to move from full-period logistics summaries to period-specific performance. It is especially useful for checking whether delivery speed, late delivery rates, and regional bottlenecks remain stable over time or worsen during specific periods.

---

### 2.2 Customer Region slicer

- **Field used:** `customers_final[Customer Region]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the entire page to customers belonging to one or more selected Brazilian macro-regions
- **Behavior:** Allows the viewer to isolate logistics performance for a specific customer geography, including delivery speed, delivery reliability, and regional experience gaps

**Business use:**  
This slicer answers whether logistics performance differs structurally by customer geography. It helps test whether certain regions systematically experience slower deliveries, higher lateness, or weaker reliability than others.

---

### 2.3 Order Type slicer

- **Field used:** `orders_final[Order Type]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page by fulfillment structure, distinguishing between single-seller and multi-seller orders
- **Behavior:** Allows the viewer to compare logistics outcomes across simpler and more complex fulfillment models while keeping the rest of the page logic unchanged

**Business use:**  
This slicer helps test whether fulfillment complexity is associated with weaker delivery performance. It is useful for checking whether delivery time and late delivery risk differ meaningfully between single-seller and multi-seller orders.

---

## 3. KPI cards

### 3.1 Avg Delivery Time (Days)

- **Display Name:** Avg Delivery Time (Days)
- **Type:** Card
- **Measure:** [Avg Delivery Time (Days)](../reference/measures-and-calculated-columns.md#avg-delivery-time-days)
- **Used As:** Headline logistics speed KPI showing the average end-to-end delivery duration for valid delivered orders

**Business Definition:**  
Represents the average number of days between order purchase and customer delivery for orders that qualify as **valid delivered orders**, meaning the order was delivered, passed timeline quality checks, was not flagged as hanging, and had `payment_value >= 1`.

**Documentation Notes:**

➡︎ This is the baseline delivery-speed KPI for the page  
➡︎ It is calculated at the **order level**, not the item level  
➡︎ It reflects the full customer-facing delivery experience from purchase to final delivery  
➡︎ Higher values indicate slower logistics performance  

---

### 3.2 On-Time Delivery Rate %

- **Display Name:** On-Time Delivery Rate 
- **Type:** Card
- **Measure:** [On-Time Delivery Rate %](../reference/measures-and-calculated-columns.md#on-time-delivery-rate-percent)
- **Used As:** Headline logistics reliability KPI showing the share of valid delivered orders that arrived on or before the estimated delivery date

**Business Definition:**  
Represents the percentage of **valid delivered orders** that were delivered on time, calculated as the complement of the late delivery rate. An order is considered on time when the actual customer delivery date is not later than the estimated delivery date.

**Documentation Notes:**

➡︎ This is the positive reliability counterpart to **Late Delivery Rate %**  
➡︎ It is derived as `1 - [Late Delivery Rate %]`  
➡︎ It is based only on the cleaned cohort of valid delivered orders  
➡︎ Higher values indicate stronger delivery reliability and better expectation management  

---

### 3.3 Avg Delivery Gap vs ETA

- **Display Name:** Avg Delivery Gap vs ETA
- **Type:** Card
- **Field:** `orders_final[delay_vs_eta]`
- **Aggregation:** Average
- **Visual-level Filters:**  
  - `orders_final[order_status] = "delivered"`  
  - `orders_final[timeline_is_valid] = 1`
- **Used As:** Headline schedule-performance KPI showing how far actual delivery timing deviates from the estimated delivery date on average

**Business Definition:**  
Represents the average difference, in days, between the **estimated delivery date** and the **actual customer delivery date** for delivered orders with valid timeline sequencing in the current filter context.

**Documentation Notes:**

➡︎ Uses the calculated column [`orders_final[delay_vs_eta]`](../reference/measures-and-calculated-columns.md#delay-vs-eta) with **Average** aggregation  
➡︎ Applies visual-level filters restricting the card to delivered orders with `timeline_is_valid = 1`  
➡︎ Negative values indicate orders were delivered **earlier** than estimated, positive values indicate orders were delivered **later** than estimated  
➡︎ Measures average schedule deviation relative to the promised delivery date  
➡︎ Complements [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-) by showing the average size and direction of the timing gap, not just the share of missed deadlines  

---

### 3.4 Severely Late Orders %

- **Display Name:** Severely Late Orders %
- **Type:** Card
- **Measure:** [Severely Late (>3d) %](../reference/measures-and-calculated-columns.md#severely-late-3d-)
- **Used As:** Headline severity KPI showing the share of valid delivered orders that were delivered more than 3 days after the estimated delivery date

**Business Definition:**  
Represents the percentage of **valid delivered orders** that fall into the `Severely Late (>3d)` delay bucket, meaning the actual customer delivery date occurred more than three days after the estimated delivery date.

**Documentation Notes:**

➡︎ This KPI isolates the most operationally severe late deliveries rather than all late orders  
➡︎ It is calculated as the share of [`Valid Delivered Orders`](../reference/measures-and-calculated-columns.md#valid-delivered-orders) classified as `Severely Late (>3d)`  
➡︎ It complements [`On-Time Delivery Rate %`](../reference/measures-and-calculated-columns.md#on-time-delivery-rate-percent) and [`Late Delivery Rate %`](../reference/measures-and-calculated-columns.md#late-delivery-rate-percent) by focusing specifically on high-impact delivery failures  
➡︎ Higher values indicate more serious reliability breakdowns and a worse customer delivery experience  

---

### 3.5 Valid Delivered Orders

- **Display Name:** Valid Delivered Orders
- **Type:** Card
- **Measure:** [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Used As:** Baseline cohort-size KPI showing the number of orders included in the page’s core logistics metrics

**Business Definition:**  
Represents the number of distinct orders that qualify as **valid delivered orders**, meaning the order was delivered, passed timeline quality checks, was not flagged as hanging, and had `payment_value >= 1`.

**Documentation Notes:**

➡︎ This is the denominator and baseline order-volume KPI for multiple logistics measures on the page  
➡︎ It uses the cleaned commercial cohort rather than all historical orders  
➡︎ Each order is counted only once using distinct `order_id`  
➡︎ It defines the population used for delivery speed, reliability, and delay-severity analysis  

---

### 3.6 Single-Seller Orders

- **Display Name:** Single-Seller Orders
- **Type:** Card
- **Field:** `orders_final[order_id]`
- **Aggregation:** Count
- **Visual-level Filters:**  
  - `orders_final[is_hanging] = 0`  
  - `orders_final[Order Type] = "Single-Seller"`  
  - `orders_final[order_status] = "delivered"`  
  - `orders_final[timeline_is_valid] = 1`
- **Used As:** Fulfillment-structure context KPI showing how many delivered, timeline-valid, non-hanging orders were fulfilled by a single seller

**Business Definition:**  
Represents the number of delivered orders in the current filter context that passed timeline quality checks, were not flagged as hanging, and were classified as [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) = `Single-Seller`.

**Documentation Notes:**

➡︎ Uses `orders_final[order_id]` with **Count** aggregation directly in the visual  
➡︎ Applies visual-level filters restricting the card to delivered, timeline-valid, non-hanging orders only  
➡︎ Filters specifically to [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) = `Single-Seller`  
➡︎ Serves as a fulfillment-structure context card rather than a reusable DAX measure  
➡︎ Useful for showing how much of the logistics analysis is driven by simpler one-seller fulfillment cases  

---

### 3.7 Multi-Seller Orders

- **Display Name:** Multi-Seller Orders
- **Type:** Card
- **Field:** `orders_final[order_id]`
- **Aggregation:** Count
- **Visual-level Filters:**  
  - `orders_final[is_hanging] = 0`  
  - `orders_final[Order Type] = "Multi-Seller"`  
  - `orders_final[order_status] = "delivered"`  
  - `orders_final[timeline_is_valid] = 1`
- **Used As:** Fulfillment-structure context KPI showing how many delivered, timeline-valid, non-hanging orders were fulfilled by more than one seller

**Business Definition:**  
Represents the number of delivered orders in the current filter context that passed timeline quality checks, were not flagged as hanging, and were classified as [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) = `Multi-Seller`.

**Documentation Notes:**

➡︎ Uses `orders_final[order_id]` with **Count** aggregation directly in the visual  
➡︎ Applies visual-level filters restricting the card to delivered, timeline-valid, non-hanging orders only  
➡︎ Filters specifically to [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) = `Multi-Seller`  
➡︎ Serves as a fulfillment-structure context card rather than a reusable DAX measure  
➡︎ Useful for showing the relative scale of more complex fulfillment cases within the logistics cohort  

---

### 3.8 Worst Region (by Late Delivery Rate)

- **Display Name:** Worst Region (by Late Delivery Rate)
- **Type:** Card
- **Measure:** [Worst Region Late Rate](../reference/measures-and-calculated-columns.md#worst-region-late-rate)
- **Used As:** Headline regional risk KPI identifying the customer region with the highest late delivery rate in the current filter context

**Business Definition:**  
Returns the name of the customer region with the highest [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-) among the regions visible in the current filter context.

**Documentation Notes:**

➡︎ This is a text-based ranking KPI rather than a numeric performance measure  
➡︎ It evaluates [`Late Delivery Rate %`](../reference/measures-and-calculated-columns.md#late-delivery-rate-) across the visible values of `customers_final[Customer Region]`  
➡︎ It returns the worst-performing customer region from a delivery reliability perspective  
➡︎ It responds dynamically to page filters such as `Reporting Period`, `Customer Region`, and `Order Type`  
➡︎ It is useful for quickly surfacing the region with the weakest delivery reliability on the page  

---

## 4. Charts and Visuals

### 4.1 Delivery Time Breakdown by Customer Region

- **Chart Type:** Stacked bar chart
- **Title:** Delivery Time Breakdown by Customer Region
- **Subtitle:** *Regional delivery differences are driven mainly by transit time, not handling time*
- **Y-axis:** `customers_final[Customer Region]`
- **X-axis Measures:** [Transit Time (Days)](../reference/measures-and-calculated-columns.md#transit-time-days), [Order Processing Time (Days)](../reference/measures-and-calculated-columns.md#order-processing-time-days)
- **Tooltips:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-), [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Visual-level Filters:** None
- **Used As:** Regional delivery decomposition visual showing how total customer delivery time is split between pre-transit order processing and carrier-to-customer transit

**Business Definition:**  
This chart compares average delivery duration across customer regions by splitting the journey into two operational stages: **Order Processing Time**, measured from purchase to carrier handoff, and **Transit Time**, measured from carrier handoff to final customer delivery. It helps distinguish whether slower regional delivery performance is driven more by pre-shipment processing or by the transport leg itself.

**Documentation Notes:**

➡︎ Uses a stacked bar layout to show total delivery time while preserving the contribution of each stage  
➡︎ Compares delivery speed across `customers_final[Customer Region]` rather than across individual states or cities  
➡︎ Makes visible that most cross-region delivery differences come from the transit component rather than the processing component  
➡︎ Uses [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-) and [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders) in the tooltip to connect delivery speed with reliability and sample size  
➡︎ Supports the page’s broader logistics question by showing where customer delivery time is structurally longer and what stage contributes most to that delay  

**Interpretation Notes:**

* Longer total bars indicate slower average delivery performance for that customer region
* A larger dark-blue segment indicates longer carrier-to-customer transit time
* A larger light-blue segment indicates longer purchase-to-carrier processing time
* When processing time stays relatively stable but transit time expands, the likely bottleneck is structural logistics distance or network reach rather than seller-side execution alone

---

### 4.2 Late Delivery Rate % by Customer Region

- **Chart Type:** Column chart
- **Title:** Late Delivery Rate % by Customer Region
- **Subtitle:** *Share of delivered orders that arrived after the estimated date, by customer region*
- **X-axis:** `customers_final[Customer Region]`
- **Y-axis Measure:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-)
- **Tooltips:** [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Visual-level Filters:** None
- **Used As:** Regional reliability comparison visual showing where customers are most likely to receive orders after the promised delivery date

**Business Definition:**  
This chart compares the share of [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders) that were delivered late across customer regions. It highlights where delivery reliability is weakest from the customer perspective and makes it easier to distinguish slower regions from truly less reliable ones.

**Documentation Notes:**

➡︎ Uses [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-) as the primary reliability metric  
➡︎ Compares customer-facing delivery reliability across `customers_final[Customer Region]`  
➡︎ Includes [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders) in the tooltip to provide sample-size context for each regional result  
➡︎ Uses a platform-average reference line to show which regions are performing above or below the marketplace baseline  
➡︎ Supports the logistics story by surfacing where promised delivery dates are missed most often, not just where delivery is slowest on average  

**Interpretation Notes:**

* Higher bars indicate weaker delivery reliability and a greater share of missed delivery promises
* Regions above the platform average line are underperforming relative to the marketplace baseline
* A region can have long delivery times without having the highest late-delivery rate, which is why this chart complements speed-based visuals rather than replacing them
* This visual is especially useful for distinguishing structural slowness from operational inconsistency

---

### 4.3 Order Fulfillment Performance: Speed vs Reliability

- **Chart Type:** Clustered column chart
- **Title:** Order Fulfillment Performance: Speed vs Reliability
- **Subtitle:** *Single-seller and multi-seller orders show materially different delivery patterns and should not be analyzed as one homogeneous logistics group*
- **Category Axis:** [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type)
- **Left-side Y-axis Measure:** [Avg Delivery Time (Days)](../reference/measures-and-calculated-columns.md#avg-delivery-time-days)
- **Right-side Y-axis Measure:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-)
- **Tooltips:** [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Visual-level Filters:** None
- **Used As:** Fulfillment-structure comparison visual showing whether single-seller and multi-seller orders differ in both delivery speed and delivery reliability

**Business Definition:**  
This chart compares the two fulfillment structures captured in [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) — **Single-Seller** and **Multi-Seller** — across two logistics outcomes: average end-to-end delivery time and late delivery rate. Its purpose is not route-level diagnosis, but structural comparison. It helps determine whether these two order types behave similarly enough to be analyzed together or differently enough to justify separate treatment in later logistics analysis.

**Documentation Notes:**

➡︎ Uses [`orders_final[Order Type]`](../reference/measures-and-calculated-columns.md#order-type) as the category field on the x-axis  
➡︎ Uses [`Avg Delivery Time (Days)`](../reference/measures-and-calculated-columns.md#avg-delivery-time-days) on the left-side y-axis to compare fulfillment speed  
➡︎ Uses [`Late Delivery Rate %`](../reference/measures-and-calculated-columns.md#late-delivery-rate-) on the right-side y-axis to compare delivery reliability against the estimated date  
➡︎ Includes [`Valid Delivered Orders`](../reference/measures-and-calculated-columns.md#valid-delivered-orders) in the tooltip to provide cohort-size context for each order type  
➡︎ Supports the methodological decision to assess single-seller and multi-seller orders separately in downstream logistics analysis rather than blending them into one combined order population  

**Interpretation Notes:**

* Lower average delivery time indicates faster customer fulfillment
* Lower late delivery rate indicates stronger delivery reliability against the promised date
* In this dashboard, multi-seller orders appear to outperform single-seller orders on both measures
* This should be interpreted as an observed structural difference in this dataset, not as proof that multi-seller fulfillment is inherently operationally superior
* The sample is highly imbalanced: single-seller orders represent the overwhelming majority of the logistics cohort, while multi-seller orders form a much smaller subgroup
* Because the multi-seller cohort is much smaller, its results should be interpreted with caution and in conjunction with the KPI cards showing exact order counts for each fulfillment type
* The main analytical value of this visual is to justify treating the two fulfillment structures separately in the subsequent Regional Delivery Flows analysis

---

### 4.4 Delivery Reliability by Region

- **Chart Type:** 100% stacked bar chart
- **Title:** Delivery Reliability by Region
- **Category Axis:** `customers_final[Customer Region]`
- **Value Axis:** [`Valid Delivered Orders`](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Legend:** [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category)
- **Visual-level Filters:** None
- **Used As:** Regional delivery-outcome composition visual showing how the mix of on-time, mildly late, and severely late orders differs across customer regions

**Business Definition:**  
This chart breaks down the composition of [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders) across customer regions using [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category). It shows what share of delivered orders in each region arrived **On-Time**, **Late (1–3d)**, or **Severely Late (>3d)**, making it possible to compare not just overall lateness but the severity profile of delivery outcomes.

**Documentation Notes:**

➡︎ Uses a 100% stacked layout so each region is evaluated as a proportional distribution, rather than by raw order volume  
➡︎ Uses [`Valid Delivered Orders`](../reference/measures-and-calculated-columns.md#valid-delivered-orders) on the value axis and [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category) as the legend split  
➡︎ Compares the reliability mix across `customers_final[Customer Region]`, not just total late-delivery rate  
➡︎ Distinguishes mild lateness from severe lateness, which adds more operational meaning than a binary on-time vs late view  
➡︎ By default, the chart shows the overall regional reliability mix across the current filtered order population, including both single-seller and multi-seller orders  
➡︎ The visual remains interactive through page slicers such as `Reporting Period`, `Customer Region`, and `Order Type`, allowing the viewer to isolate fulfillment structures or regional subsets when needed  
➡︎ The late segments are relatively small, so a horizontal zoom slider is enabled to let the viewer enlarge that section and inspect smaller categories more clearly  

**Interpretation Notes:**

* Larger green sections indicate a higher share of **on-time deliveries** and therefore stronger delivery reliability
* Larger blue sections indicate more orders that were late by 1 to 3 days
* Larger red sections indicate a higher concentration of severe delivery failures, where orders arrived more than 3 days late
* Regions can have similar overall on-time shares but still differ meaningfully in the balance between mild lateness and severe lateness
* Because this visual shows proportional composition, it should be interpreted alongside [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders) and the regional late-rate chart for full context

---

## 5. Page summary

**Main Insights:**

➡︎ The page shows that overall delivery performance is not uniform across the marketplace and varies meaningfully by customer region
➡︎ Regional delivery differences are driven primarily by transit time, while order processing time remains comparatively stable across regions
➡︎ The North is the slowest region by average delivery time, but the Northeast has the highest late delivery rate, showing that the slowest region is not necessarily the least reliable
➡︎ The regional reliability view shows that most orders are still delivered on time, but the severity mix of late deliveries differs across regions, with the Northeast standing out as the most operationally fragile
➡︎ The comparison between single-seller and multi-seller orders shows that these fulfillment structures behave differently in this dataset, supporting the decision to avoid treating them as one homogeneous logistics population
➡︎ Together, the KPIs and visuals show both the speed and the reliability of delivery performance, making it possible to distinguish structural distance effects from weaker delivery execution

**Why This Logistics Page Matters:**

➡︎ It gives decision-makers a focused view of logistics performance rather than general marketplace activity
➡︎ It shows where customer delivery experience is weakest and which regions face the greatest operational friction
➡︎ It separates delivery speed from delivery reliability, which is essential because those two dimensions do not always point to the same underperforming region
➡︎ It provides the operational context needed for deeper analysis of regional delivery flows and fulfillment structure on subsequent pages














## Order inclusion criteria

All analyses related to logistics performance, delivery behavior, and revenue are restricted to completed and analytically valid orders only. An order is included if it satisfies all of the following conditions:

> 1. Final delivery status: Only orders with order_status = "delivered" are considered for logistics and delivery-related metrics.  
> 2. Finalized lifecycle: Orders must have is_hanging = 0, ensuring that only orders that have reached a terminal state are included.  
> 3. Valid process timeline: Orders must satisfy timeline_is_valid = 1, meaning the sequence of key events (e.g., purchase, approval, carrier, delivery timestamps) follows a logically consistent chronological order without anomalies.

Orders that do not meet these criteria, including those with statuses such as created, invoiced, processing, shipped, canceled, or unavailable, - are excluded from logistics and delivery analyses, as they do not represent complete and comparable delivery outcomes.

Within this filtered dataset, additional segmentation (e.g., single-seller vs. multi-seller orders) is applied only after these validity constraints are enforced, ensuring that comparisons are made on a consistent and fully observable subset of completed orders.


## Cards/KPIs:

### 1. Avg Delivery Time (Days) ➜ calculates the average number of days between order placement and customer delivery for completed orders. Only orders that meet the following criteria are included: delivered status (order_status = "delivered"), valid chronological sequence of events (timeline_is_valid = 1), and finalized orders (is_hanging = 0). The calculation is performed using the delivery time in days recorded at the order level and represents the mean delivery duration across all qualifying orders.
```
Avg Delivery Time (Days) = 
CALCULATE(
    AVERAGE(orders_final[order_to_delivery_days]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```
---
 
### 2. Late Delivery Rate ➜ This measure represents the proportion of delivered orders that were delivered later than the estimated delivery date. It is calculated as the ratio of orders flagged as late (is_late = TRUE) to the total number of valid delivered orders. Only orders that meet all data quality and completeness criteria are included: delivered status (order_status = "delivered"), valid chronological event sequence (timeline_is_valid = 1), finalized orders (is_hanging = 0), and valid payment records (payment_value >= 1). The result reflects the percentage of late deliveries within a consistent and fully validated subset of completed orders.
```
Late Delivery Rate = 
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

```
Valid Delivered Orders = 
CALCULATE(
    DISTINCTCOUNT(orders_final[order_id]),
    orders_final[order_status] = "delivered",
    orders_final[timeline_is_valid] = 1,
    orders_final[is_hanging] = 0,
    order_payments_final[payment_value] >= 1
)
```
---

### Worst Region (by Average Delivery Time) ➜ This measure identifies the customer region with the highest average delivery time. It evaluates the average delivery duration across all regions and returns the region with the maximum value, effectively highlighting the slowest-performing region in terms of delivery speed based on valid delivered orders.
```
Worst Region Avg Delivery = 
TOPN(1, VALUES(customers_final[Customer Region]), [Avg Delivery Time (Days)], DESC)
```
---

### Worst Region (by Late Delivery Rate) ➜ This measure identifies the customer region with the highest late delivery rate. It evaluates the late delivery rate across all customer regions and returns the region where the proportion of late deliveries is maximized, based only on valid delivered orders that meet all data quality and completeness criteria (including finalized orders, valid timelines, and valid payment records). The result highlights the region with the poorest performance in terms of delivery punctuality relative to estimated delivery dates.
```
Worst Region Late Rate = 
MAXX(
    TOPN(
        1,
        VALUES(customers_final[Customer Region]),
        [Late Delivery Rate],
        DESC
    ),
    customers_final[Customer Region]
)
```
---

## Charts

### Delivery Performance by Region (Avg Delivery Time in Days)
This chart shows the average time it takes for orders to be delivered to customers in each region, based only on valid delivered orders. Each bar represents a customer region and reflects the mean delivery duration (in days) experienced by customers.

The purpose of this visualization is to compare logistical efficiency across regions and identify where deliveries take longer on average. Higher values indicate slower delivery performance, while lower values indicate faster fulfillment. This helps highlight geographic disparities in delivery speed and potential operational inefficiencies across regions.

### Late Delivery Rate by Customer Region (%)
This chart displays the proportion of orders that were delivered later than the estimated delivery date in each customer region. The late delivery rate is calculated as the percentage of delivered orders that exceeded their promised delivery date, considering only valid and complete orders.

Each bar represents the share of late deliveries within a region’s total valid delivered orders. Higher percentages indicate poorer adherence to estimated delivery timelines, while lower percentages suggest better punctuality and reliability. This visualization is used to assess service quality and SLA compliance across regions.



```
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





HEATMAP: INTRA AND INTER-REGION LATE DELIVERY RATE:
I will be filtering out multi-seller orders (1.3%) -> reasoning: Because delivery timestamps are recorded at the order level, attribution within multi-seller orders is ambiguous. I therefore used single-seller orders (98.7%) as the primary analytical base for clean seller-to-customer mapping. I validated that multi-seller orders represent only 1.3% of volume and tested their impact separately to ensure no material bias

Column in `orders_final`: **is_late** ➜ boolean
```
is_late = 
orders_final[order_delivered_customer_date] >
orders_final[order_estimated_delivery_date]  
```
---

Column in `orders_final`: **Seller Count** ➜ is only computed for delivered orders (order_status = `delivered`)
```
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
---

 Column in `orders_final`: **Order Type** ➜ 
```
Order Type =
SWITCH(
    TRUE(),
    orders_final[order_status] <> "delivered", "Non-Delivered",
    [Seller Count] = 1, "Single-Seller",
    [Seller Count] > 1, "Multi-Seller",
    BLANK()
)
```



**Late Delivery Rate** ➜
```
Late Delivery Rate =
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