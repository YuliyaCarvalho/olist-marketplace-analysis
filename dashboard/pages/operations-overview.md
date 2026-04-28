# Olist Dashboard — Operations Overview

**Business Context:** *Core Question: How is fulfillment performance evolving over time?*  
This page focuses on operational execution after the order is placed. It tracks delivery speed, lateness, processing efficiency, and time-based fulfillment patterns to show whether the marketplace is operating reliably, and where execution risk is concentrated.

## 1. Report page purpose

- **Page Role:** Operational performance and fulfillment monitoring
- **Primary Objective:** Evaluate delivery efficiency, lateness, seller processing speed, and operational stability over time
- **Grain of Analysis:** Primarily order-level, with selected seller-level and monthly aggregations

**Key Business Questions:**

- How many commercially valid delivered orders are being fulfilled?
- How fast are orders moving from purchase to delivery?
- How often are orders delivered late versus on time?
- Is actual delivery performance improving or deteriorating over time?
- Are higher order volumes associated with worse delivery outcomes?
- Which sellers show unusually poor internal processing performance?


## 2. Page-level filters and navigation controls

This page includes three slicers that control the operational scope of the analysis. Together, they allow the viewer to evaluate fulfillment performance across different time periods, customer geographies, and order structures.

### Reporting Period slicer

- **Field used:** `dim_date[YearMonth Label]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to one or multiple selected reporting months
- **Behavior:** Supports flexible month-level selection, allowing the viewer to analyze operational performance across custom time windows

**Business use:**  
This slicer is used to assess how fulfillment performance changes over time. It allows the viewer to isolate specific periods and examine whether delivery speed, lateness, and processing efficiency improve or deteriorate across months.

### Customer Region slicer

- **Field used:** `customers_final[Customer Region]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to customers belonging to a selected Brazilian macro-region
- **Behavior:** Applies a regional customer filter across the operational visuals and cards

**Business use:**  
This slicer helps test whether fulfillment performance differs depending on where the customer is located. It supports regional comparison of delivery speed, lateness, and operational execution quality.

### Order Type slicer

- **Field used:** `orders_final[Order Type]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page by delivery structure and seller composition
- **Behavior:** Allows the viewer to compare operational performance across:
  - `Single-Seller`
  - `Multi-Seller`
  - `Non-Delivered`

**Business use:**  
This slicer helps isolate whether fulfillment performance differs by order complexity. In practice, the most analytically useful comparison is usually between **Single-Seller** and **Multi-Seller** delivered orders, since multi-seller fulfillment may involve more coordination complexity and weaker seller-level attribution.

**Documentation note:**  
Although the calculated column includes a `Non-Delivered` category, many measures on this page are already restricted to **valid delivered orders**, so selecting `Non-Delivered` may produce blanks or limited output in several visuals.


### Filter design note

These slicers are page-wide and affect all visuals unless a visual has been explicitly configured otherwise. Together, they allow the page to support both:
- **broad operational monitoring** across the full marketplace, and
- **focused performance analysis** by time period, region, and order type

---

## 3. KPI cards

### 3.1 Valid Delivered Orders

- **Display Name:** Valid Delivered Orders
- **Type:** Card
- **Measure:** [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Used As:** Baseline operational volume KPI showing the number of delivered orders that pass all core data-quality and commercial-validity checks

**Business Definition:**  
Represents the number of distinct delivered orders that qualify as operationally and commercially valid in the current filter context.

**Documentation Notes:**

➡︎ Includes only orders with `order_status = "delivered"`  
➡︎ Excludes orders failing the timeline quality check using `timeline_is_valid = 1`  
➡︎ Excludes hanging or operationally abnormal orders using `is_hanging = 0`  
➡︎ Excludes zero-value and micro-value transactions by requiring `payment_value >= 1`  
➡︎ Serves as the baseline order cohort for most operational KPIs on this page  

---

### 3.2 Average Delivery Time

- **Display Name:** Average Delivery Time
- **Type:** Card
- **Measure:** [Avg Delivery Time (Days)](../reference/measures-and-calculated-columns.md#avg-delivery-time-days)
- **Used As:** Headline fulfillment-speed KPI showing the average number of days required to deliver valid orders

**Business Definition:**  
Represents the average number of days between order purchase and customer delivery for **valid delivered orders** in the current filter context.

**Documentation Notes:**

➡︎ Calculated from `orders_final[order_to_delivery_days]`  
➡︎ Includes only delivered orders that pass timeline validity and hanging-order checks  
➡︎ Excludes zero-value and micro-value transactions using `payment_value >= 1`  
➡︎ Measures end-to-end delivery speed from purchase to final customer delivery  
➡︎ Serves as a core operational efficiency KPI for the page  

---

### 3.3 On-Time Delivery Rate

- **Display Name:** On-Time Delivery Rate
- **Type:** Card
- **Measure:** [On-Time Delivery Rate %](../reference/measures-and-calculated-columns.md#on-time-delivery-rate-percent)
- **Used As:** Headline delivery-reliability KPI showing the share of valid delivered orders that arrived on or before the estimated delivery date

**Business Definition:**  
Represents the percentage of **valid delivered orders** that were delivered on time, defined as not being flagged as late (`is_late = 0`).

**Documentation Notes:**

➡︎ Calculated as `1 - Late Delivery Rate %`  
➡︎ Uses the same cleaned valid-order cohort as the rest of the page  
➡︎ Treats on-time performance as the complement of late delivery performance  
➡︎ Measures reliability against the promised delivery deadline, rather than absolute delivery speed  
➡︎ Best interpreted together with `Average Delivery Time`, since fast delivery does not always guarantee better deadline performance  

---

### 3.4 Late Delivery Rate

- **Display Name:** Late Delivery Rate
- **Type:** Card
- **Measure:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-percent)
- **Used As:** Headline delivery-risk KPI showing the share of valid delivered orders that arrived after the estimated delivery date

**Business Definition:**  
Represents the percentage of **valid delivered orders** that were delivered late in the current filter context.

**Documentation Notes:**

➡︎ Uses `Late Delivery Rate %` as the underlying measure  
➡︎ Restricts the calculation to the cleaned valid delivered order cohort  
➡︎ Identifies lateness using the `is_late` flag  
➡︎ Measures failure against the promised delivery timeline rather than absolute delivery speed  
➡︎ Complements `On-Time Delivery Rate` as the direct view of deadline miss risk  

---

### 3.5 Avg Delivery Gap vs ETA

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

➡︎ Uses the calculated column `orders_final[delay_vs_eta]` with **Average** aggregation  
➡︎ Applies visual-level filters restricting the card to delivered orders with `timeline_is_valid = 1`  
➡︎ Negative values indicate orders were delivered **earlier** than estimated, positive values indicate orders were delivered **later** than estimated  
➡︎ Measures average schedule deviation relative to the promised delivery date  
➡︎ Complements `Late Delivery Rate` by showing the average size and direction of the timing gap, not just the share of missed deadlines  

---

### 3.6 Avg Approval-To-Carrier Time

- **Display Name:** Avg Approval-To-Carrier Time
- **Type:** Card
- **Field:** `orders_final[Approval To Carrier (Days Decimal)]`
- **Aggregation:** Average
- **Used As:** Headline seller-processing KPI showing the average time between order approval and carrier handoff

**Business Definition:**  
Represents the average number of days between **order approval** and **carrier handoff** for eligible orders in the current filter context.

**Documentation Notes:**

➡︎ Uses the calculated column `orders_final[Approval To Carrier (Days Decimal)]` with **Average** aggregation  
➡︎ The column only returns values for orders with `timeline_is_valid = 1`  
➡︎ The column is restricted to `Single-Seller` orders to avoid attribution ambiguity in multi-seller fulfillment  
➡︎ Returns `BLANK()` when either approval or carrier handoff timestamp is missing  
➡︎ Measures internal seller-side processing time before the order enters the delivery network  
➡︎ Best interpreted separately from delivery speed, since this KPI captures pre-shipment processing rather than end-to-end fulfillment time  

---

## 4. Charts and Visuals

### 4.1 Top 10 Sellers by Extreme Processing Delay Rate

- **Display Name:** Top 10 Sellers by Extreme Processing Delay Rate
- **Type:** Horizontal bar chart
- **Axis:** `sellers_final[Seller Label Short]`
- **Measure:** [Slow Processing Rate % (P90)](../reference/measures-and-calculated-columns.md#slow-processing-rate-percent-p90)
- **Tooltip:**  
  - [Selected Seller ID](../reference/measures-and-calculated-columns.md#selected-seller-id)  
  - [Single-Seller Orders with Approval-To-Carrier](../reference/measures-and-calculated-columns.md#single-seller-orders-with-approval-to-carrier)  
  - [Slow Processed Orders (P90)](../reference/measures-and-calculated-columns.md#slow-processed-orders-p90)  
  - `orders_final[Approval To Carrier (Days Decimal)]` aggregated as **Average**  
  - [Approval To Carrier P90](../reference/measures-and-calculated-columns.md#approval-to-carrier-p90)
- **Visual-level Filter:** [Seller Eligible for Ranking](../reference/measures-and-calculated-columns.md#seller-eligible-for-ranking) `>= 30`
- **Used As:** Seller-risk ranking view showing which sellers have the highest share of severely slow internal processing events

**Business Definition:**  
Ranks sellers by the share of their eligible orders whose **approval-to-carrier time** exceeds the platform-wide **90th percentile threshold**.

**How to Read It:**  
Each bar shows the percentage of a seller’s eligible single-seller orders whose approval-to-carrier time is unusually slow relative to the broader platform distribution. Higher values indicate more frequent extreme processing delays before the order reaches the carrier.

**Documentation Notes:**

➡︎ Uses `sellers_final[Seller Label Short]` as a shortened display label for readability, while preserving seller-level ranking  
➡︎ Uses `Slow Processing Rate % (P90)` as the x-axis metric  
➡︎ The numerator counts seller orders with `Approval To Carrier (Days Decimal)` above the platform P90 threshold  
➡︎ The denominator counts eligible orders with non-blank `Approval To Carrier (Days Decimal)`  
➡︎ Because `Approval To Carrier (Days Decimal)` is only populated for `timeline_is_valid = 1` and `Single-Seller` orders, the visual is inherently restricted to that cohort  
➡︎ A visual-level filter keeps only sellers with at least **30 eligible single-seller orders**, reducing distortion from very small samples  
➡︎ Tooltips expose the full seller ID, seller order volume, number of orders above the threshold, seller average processing time, and the platform benchmark used for comparison  

**Business Interpretation:**  
This visual identifies sellers with unusually frequent extreme pre-shipment delays. It helps separate isolated delays from structurally weak seller-side processing performance and highlights where operational bottlenecks may be concentrated before delivery even begins.

---

### 4.2 Delivery Time: Actual vs Estimated

- **Display Name:** Delivery Time: Actual vs Estimated
- **Type:** Line chart
- **Axis:** `dim_date[Month Start]`
- **Measures:**  
  - [Estimated Delivery Days](../reference/measures-and-calculated-columns.md#estimated-delivery-days)  
  - [Actual Delivery Days](../reference/measures-and-calculated-columns.md#actual-delivery-days)
- **Tooltip:** [Delivery Gap (Days)](../reference/measures-and-calculated-columns.md#delivery-gap-days)
- **Visual-level Filter:** Reporting timeline starts at **Jan 2017**
- **Used As:** Monthly fulfillment trend view comparing promised delivery lead time against actual delivery performance

**Business Definition:**  
Compares the average number of days from purchase to **estimated delivery date** versus the average number of days from purchase to **actual customer delivery** for delivered orders with valid timelines.

**How to Read It:**  
The two lines show whether the marketplace is delivering materially faster or slower than the estimated promise window. A wider gap between the estimated and actual lines indicates a larger delivery buffer, while a narrower gap suggests that actual fulfillment is moving closer to the promised deadline.

**Documentation Notes:**

➡︎ Uses `Estimated Delivery Days` to represent the average promised delivery window from purchase to estimated arrival  
➡︎ Uses `Actual Delivery Days` to represent the average realized delivery time from purchase to customer delivery  
➡︎ Both measures are restricted to delivered orders with `timeline_is_valid = 1` and `is_hanging = 0`  
➡︎ Tooltip uses `Delivery Gap (Days)` to quantify the monthly difference between actual and estimated delivery time  
➡︎ Data labels are intentionally omitted, since the primary insight comes from the relationship between the two lines rather than from reading every monthly point  
➡︎ The chart is most useful for tracking whether operational execution is consistently outperforming or drifting toward the estimated delivery promise  

**Business Interpretation:**  
This visual shows whether the marketplace is maintaining a healthy delivery buffer relative to what customers were promised. If actual delivery remains consistently below estimated delivery time, fulfillment is outperforming expectations. If the gap narrows, the platform may still be on time, but with less operational cushion.

**Data Note:**  
Although the broader calendar may include later months, some months may not appear if the filtered measures return `BLANK()` after the visual’s delivery-validity filters are applied.

---

### 4.3 Order Volume vs Late Delivery Rate Over Time

- **Display Name:** Order Volume vs Late Delivery Rate Over Time
- **Type:** Combo chart 
- **Axis:** `dim_date[Month Start]`
- **Column Measure:** [Valid Delivered Orders](../reference/measures-and-calculated-columns.md#valid-delivered-orders)
- **Line Measure:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-percent)
- **Tooltip:** [Late Delivery Rate %](../reference/measures-and-calculated-columns.md#late-delivery-rate-percent)
- **Label-support Measure:** [Late Delivery Rate % Label](../reference/measures-and-calculated-columns.md#late-delivery-rate-percent-label)
- **Visual-level Filter:** Timeline restricted to **Jan 2017 – Aug 2018**
- **Used As:** Monthly operations trend view comparing fulfilled order volume with late-delivery risk over time

**Business Definition:**  
Shows how the number of **valid delivered orders** changes over time alongside the **late delivery rate**, making it possible to assess whether higher fulfillment volume is associated with worsening delivery reliability. It shows whether higher platform-wide order demand coincides with weaker delivery reliability.

**How to Read It:**  
The blue bars show monthly valid delivered order volume, while the red line shows the share of those orders delivered late. Together, they help distinguish simple growth in activity from deterioration in operational execution. A rise in volume does not automatically imply worse delivery performance, so the chart should be read by comparing the shape of both series over time.

**Documentation Notes:**

➡︎ Uses `Valid Delivered Orders` as the monthly order-volume series  
➡︎ Uses `Late Delivery Rate %` as the monthly delivery-risk series  
➡︎ The line labels are controlled through `Late Delivery Rate % Label`, which shows values only for selected months to keep the chart readable  
➡︎ Tooltip repeats `Late Delivery Rate %` so exact monthly values remain visible without overcrowding the chart  
➡︎ The visual is intentionally restricted to **Jan 2017 – Aug 2018** to focus on the main operational period with usable monthly continuity  

**Business Interpretation:**  
This visual tests whether operational strain appears to increase as the marketplace scales. If order volume rises while late-delivery rate remains stable, operations are absorbing growth effectively. If late-delivery rate spikes during high-volume periods, that points to execution pressure, capacity strain, or weaker coordination during busier months.

---

## Page summary

The **Operations Overview** page looks at fulfillment from an execution point of view. It focuses on what happens after the order is placed: how many valid orders are being fulfilled, how quickly they move through the process, how often deadlines are missed, and whether operational performance stays stable as volume grows.

At a high level, the page shows a marketplace that is handling a large volume of delivered orders with generally strong delivery reliability. Actual delivery time remains comfortably below estimated timelines across the period, which suggests that, on average, the operation is maintaining a meaningful delivery buffer rather than simply meeting promises at the last moment. At the same time, the late-delivery trend shows that reliability is not perfectly stable: some months experience noticeable spikes, especially during higher-volume periods, indicating that operational strain is not evenly distributed over time.

The page also separates **speed**, **reliability**, and **seller-side processing** instead of treating them as the same thing. This is important, because a marketplace can deliver relatively quickly on average while still experiencing deadline misses, and it can miss deadlines for very different reasons. The approval-to-carrier metrics and seller ranking chart help isolate one specific source of friction: internal pre-shipment delay. By focusing on single-seller orders and using a P90 benchmark, the page highlights sellers whose processing is not just slow, but unusually and repeatedly slow relative to the platform standard.

Taken together, the page tells a more complete operational story: the platform is broadly functional and often delivers ahead of estimated timelines, but performance is not uniformly strong. Delivery risk rises in certain months, and some seller-level bottlenecks stand out as clear operational exceptions. That makes this page less about average performance alone and more about where fulfillment reliability begins to break under pressure.







