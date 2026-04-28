# Olist Dashboard — Regional Delivery Flows

**Business Context:** *Core Question: How does route structure affect delivery performance across seller–customer region pairs?*  
This page provides a route-level view of marketplace logistics by comparing **seller region → customer region** delivery flows. It focuses on how delivery time and late-delivery risk vary across regional corridors, and separates **single-seller** from **multi-seller** orders so structurally different fulfillment types are not blended into one heatmap.

---

## 1. Report page purpose

- **Page Role:** Route-level logistics diagnostics
- **Primary Objective:** Identify which regional seller-to-customer flows are slowest and least reliable, while comparing patterns separately for single-seller and multi-seller fulfillment
- **Main Audience:** Recruiters, hiring managers, business stakeholders, and portfolio reviewers
- **Grain of Analysis:** Primarily order-level, aggregated into **seller region × customer region** route cells
- **Main Tables Used:** `orders_final`, `customers_final`, `sellers_final`, `order_payments_final`, `dim_date`

**Key Business Questions:**

- Which seller-region → customer-region routes have the longest average delivery times?
- Which regional flows show the highest late-delivery rates?
- Do route-level logistics patterns differ between single-seller and multi-seller orders?
- Are the slowest routes also the least reliable, or do time and lateness highlight different bottlenecks?
- Which delivery corridors appear structurally fragile and may require operational attention?

---

## 2. Page-level filters and navigation controls

This page includes a `Reporting Period` slicer, that controls the time window being analyzed. 

---

### 2.1 Reporting Period slicer

- **Field used:** `dim_date[YearMonth Label]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to one or multiple selected reporting months
- **Behavior:** Supports single-month and multi-month selection, allowing the viewer to compare regional delivery flows over a custom time window rather than across the full dataset

**Business use:**  
This slicer allows the viewer to test whether route-level delivery bottlenecks are stable over time or become more pronounced during specific periods. It is useful for checking whether certain regional corridors deteriorate or improve as marketplace conditions change.

---

## 3. KPI cards

This page does not use KPI cards because its purpose is route-level structural diagnosis rather than headline summarization. The key insights emerge from comparing seller-region → customer-region flow patterns directly in the four heatmaps, where route structure matters more than top-line aggregate indicators.

---

## 4. Charts and Visuals

### 4.1 Regional Delivery Performance: Average Delivery Time (Days) — Single-Seller Orders

- **Chart Type:** Python heatmap
- **Title:** Regional Delivery Performance: Average Delivery Time (Days)
- **Section Label:** *Single-Seller Orders*
- **Rows:** `Seller Region`
- **Columns:** `Customer Region`
- **Cell Value:** Average Delivery Time (Days)
- **Visual-level Filters:**  
  - `orders_final[Order Type] = "Single-Seller"`
- **Used As:** Route-level speed heatmap showing how average delivery time varies across seller-region → customer-region flows for single-seller orders

**Business Definition:**  
This heatmap shows the average number of days required to deliver orders across regional seller-to-customer corridors, restricted to **single-seller orders**. Each cell represents one route, allowing the viewer to identify where customer delivery is structurally slower depending on the combination of seller origin region and customer destination region.

**Documentation Notes:**

➡︎ Uses seller region on rows and customer region on columns to create a true route matrix rather than a customer-only or seller-only comparison  
➡︎ Restricts the visual to `Single-Seller` orders so each route reflects a simpler and more attributable fulfillment structure  
➡︎ Uses average delivery time in days as the cell value, making each route directly comparable on a customer-facing speed basis  
➡︎ Uses a centered diverging color scale so cells below the page average appear greener, near-average cells appear lighter, and slower routes appear redder  
➡︎ Displays the exact average value inside each cell to preserve interpretability beyond color intensity alone  
➡︎ Serves as the route-speed baseline for comparison against the corresponding late-delivery heatmap  

**Interpretation Notes:**

* Greener cells indicate faster-than-average delivery routes
* Redder cells indicate slower-than-average delivery corridors
* Vertical patterns show which customer regions are broadly harder to serve across multiple seller origins
* Horizontal patterns show which seller regions tend to ship more slowly across multiple customer destinations
* A route can be slow without necessarily being the worst on late-delivery rate, so this visual should be read together with the reliability heatmap

---

### 4.2 Regional Delivery Performance: Average Delivery Time (Days) — Multi-Seller Orders

- **Chart Type:** Python heatmap
- **Title:** Regional Delivery Performance: Average Delivery Time (Days)
- **Section Label:** *Multi-Seller Orders*
- **Rows:** `Seller Region`
- **Columns:** `Customer Region`
- **Cell Value:** Average Delivery Time (Days)
- **Visual-level Filters:**  
  - `orders_final[Order Type] = "Multi-Seller"`
- **Used As:** Route-level speed heatmap showing how average delivery time varies across seller-region → customer-region flows for multi-seller orders

**Business Definition:**  
This heatmap shows the average number of days required to deliver orders across regional seller-to-customer corridors, restricted to **multi-seller orders**. It is designed to show how the route structure behaves when fulfillment involves more than one seller and therefore may follow different operational patterns from single-seller orders.

**Documentation Notes:**

➡︎ Uses the same seller-region × customer-region route structure as the single-seller version, enabling direct visual comparison  
➡︎ Restricts the visual to `Multi-Seller` orders so route behavior is not blended with the much larger single-seller cohort  
➡︎ Uses average delivery time in days as the cell value, preserving comparability with the single-seller heatmap above  
➡︎ Uses a centered diverging color scale to highlight which multi-seller routes are relatively faster or slower within that subgroup  
➡︎ Displays exact values inside each cell, which is especially important because the multi-seller matrix is sparser and visually uneven  
➡︎ Exists primarily as a structural comparison view rather than a headline operational benchmark, because the multi-seller cohort is materially smaller and more irregular  

**Interpretation Notes:**

* Greener cells indicate faster multi-seller routes relative to that subgroup’s distribution
* Redder cells indicate slower multi-seller corridors
* Missing or sparse cells reflect limited route coverage rather than necessarily good or bad performance
* This heatmap should be interpreted cautiously because the multi-seller cohort is much smaller and less evenly distributed across routes
* Its main value is comparative: it shows that multi-seller routes should not simply be assumed to follow the same pattern as single-seller flows

---

### 4.3 Regional Delivery Performance: Late Delivery Rate (%) — Single-Seller Orders

- **Chart Type:** Python heatmap
- **Title:** Regional Delivery Performance: Late Delivery Rate (%)
- **Section Label:** *Single-Seller Orders*
- **Rows:** `Seller Region`
- **Columns:** `Customer Region`
- **Cell Value:** Late Delivery Rate (%)
- **Visual-level Filters:**  
  - `orders_final[Order Type] = "Single-Seller"`
- **Used As:** Route-level reliability heatmap showing how late-delivery risk varies across seller-region → customer-region flows for single-seller orders

**Business Definition:**  
This heatmap shows the percentage of orders delivered after the estimated date across regional seller-to-customer corridors, restricted to **single-seller orders**. Each cell captures route-level reliability rather than speed, making it possible to identify where delivery promises are most often missed.

**Documentation Notes:**

➡︎ Uses seller region on rows and customer region on columns to diagnose late-delivery risk at the route level  
➡︎ Restricts the visual to `Single-Seller` orders to preserve route attribution clarity and comparability across cells  
➡︎ Uses late-delivery rate as the cell value, allowing reliability to be compared independently of average delivery time  
➡︎ Uses a centered diverging color scale so relatively reliable routes appear greener and relatively fragile routes appear redder  
➡︎ Displays exact percentage labels inside each cell to preserve interpretability and avoid relying on color alone  
➡︎ Complements the average-delivery-time heatmap by showing that the slowest routes are not always the ones with the highest lateness risk  

**Interpretation Notes:**

* Greener cells indicate lower route-level late-delivery risk
* Redder cells indicate weaker reliability and a higher share of missed delivery promises
* Some corridors may be slow but still relatively predictable, while others may be less slow on average but more operationally inconsistent
* Vertical and horizontal patterns help identify whether reliability issues are more strongly associated with destination difficulty or seller-origin weakness
* This visual should be interpreted together with the single-seller average-delivery-time heatmap to separate slowness from unreliability

---

### 4.4 Regional Delivery Performance: Late Delivery Rate (%) — Multi-Seller Orders

- **Chart Type:** Python heatmap
- **Title:** Regional Delivery Performance: Late Delivery Rate (%)
- **Section Label:** *Multi-Seller Orders*
- **Rows:** `Seller Region`
- **Columns:** `Customer Region`
- **Cell Value:** Late Delivery Rate (%)
- **Visual-level Filters:**  
  - `orders_final[Order Type] = "Multi-Seller"`
- **Used As:** Route-level reliability heatmap showing how late-delivery risk varies across seller-region → customer-region flows for multi-seller orders

**Business Definition:**  
This heatmap shows the percentage of orders delivered after the estimated date across regional seller-to-customer corridors, restricted to **multi-seller orders**. It is designed to show how route-level reliability behaves under a more complex fulfillment structure and whether those patterns differ from single-seller flows.

**Documentation Notes:**

➡︎ Uses the same seller-region × customer-region matrix structure as the single-seller reliability heatmap, enabling direct subgroup comparison  
➡︎ Restricts the visual to `Multi-Seller` orders so structurally different fulfillment cases are not mixed into the single-seller route analysis  
➡︎ Uses late-delivery rate as the cell value, focusing the visual on route-level reliability rather than delivery speed  
➡︎ Uses a centered diverging color scale to highlight relatively more and less reliable corridors within the multi-seller subgroup  
➡︎ Displays exact percentage labels inside each cell, which is important because the matrix is sparse and some route cells are based on a much smaller underlying subgroup  
➡︎ Should be read as a structural diagnostic, not as a standalone performance ranking, because multi-seller route coverage is limited and irregular  

**Interpretation Notes:**

* Greener cells indicate lower late-delivery risk within the multi-seller subgroup
* Redder cells indicate weaker delivery reliability and higher operational fragility
* Sparse coverage means missing cells should be interpreted as absent or insufficient route presence, not as neutral performance
* Because the multi-seller cohort is much smaller, route-level percentages may be more volatile than in the single-seller view
* The main analytical value is comparative: it shows whether route-level reliability patterns remain similar or change when fulfillment complexity increases

---

## 5. Page summary

**Main Insights:**

➡︎ The page shows that delivery performance is not only region-dependent but also **route-dependent**, meaning seller origin and customer destination interact to produce very different outcomes  
➡︎ The average-delivery-time heatmaps show, that some seller–customer corridors are structurally slower than others, and those differences are not captured by customer-region summaries alone  
➡︎ The late-delivery heatmaps show, that slow routes are not always the least reliable, making it important to separate speed from missed-promise risk  
➡︎ Single-seller and multi-seller heatmaps do not form one uniform pattern, supporting the decision to analyze these fulfillment structures separately rather than blending them into one route matrix  
➡︎ The multi-seller heatmaps are visibly sparser and more irregular, reinforcing that this subgroup is structurally different and should be interpreted more cautiously  
➡︎ Together, the four visuals turn geography into a true logistics network view by showing where operational friction emerges across seller–customer corridors, rather than within regions alone

**Why This Regional Delivery Flows Page Matters:**

➡︎ It gives decision-makers a route-level diagnostic view that goes beyond high-level regional averages  
➡︎ It helps identify which seller-to-customer corridors are structurally slow or fragile and may deserve operational attention  
➡︎ It separates delivery speed from delivery reliability, which is essential because those two route problems do not always overlap  
➡︎ It provides the deepest spatial logistics view in the dashboard and complements the earlier Logistics Overview page by showing where regional bottlenecks actually come from

---


All four visuals on this page are implemented as Python heatmaps in Power BI; technical plotting code is documented separately in [`regional-delivery-flows-python-visuals.md`](../technical-notes/regional-delivery-flows-python-visuals.md)