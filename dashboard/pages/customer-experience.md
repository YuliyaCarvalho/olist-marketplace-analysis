# Olist Dashboard — Customer Experience

**Business Context:** *Core Question: How do delivery delays affect customer satisfaction — and how does that effect change across shopping periods?*  
This page examines customer experience through the lens of review behavior, delivery performance, and shopping-period sensitivity. It focuses on how delivery delays influence customer satisfaction, how dissatisfaction escalates as lateness becomes more severe, and whether certain shopping periods are more sensitive to poor delivery execution.

## 1. Report page purpose

- **Page Role:** Customer experience and satisfaction overview  
- **Primary Objective:** Assess how delivery performance affects review outcomes and identify whether dissatisfaction patterns intensify across specific shopping periods  
- **Grain of Analysis:** Primarily order-level, with aggregated views across review score, delay severity, and shopping period  


**Key Business Questions:**

- How are review scores distributed across the marketplace?
- How strongly does customer dissatisfaction increase as delivery delays become more severe?
- How does average review score change across delivery-delay categories?
- Are some shopping periods more sensitive to poor delivery performance than others?
- How much revenue is associated with dissatisfied orders across different delay-severity groups?

---

## 2. Page-level filters and navigation controls

This page includes two dropdown slicers and one bookmark-based year selector that together control the reporting window and customer geography being analyzed. These controls are designed to let the viewer move between broad customer experience patterns and narrower time- or region-specific slices without changing the logic of the page.

### 2.1 Customer Region slicer

- **Field used:** `customers_final[Customer Region]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the entire page to customers belonging to one or more selected Brazilian macro-regions
- **Behavior:** Allows the viewer to isolate customer experience patterns by region, including review behavior, delay sensitivity, average satisfaction, and revenue at risk

**Business use:**  
This slicer helps test whether customer satisfaction and delivery-related dissatisfaction differ structurally by geography. It is useful for checking whether some regions are more exposed to low reviews, stronger delay penalties, or weaker customer experience overall.

### 2.2 Reporting Period slicer

- **Field used:** `dim_date[YearMonth Label]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to one or multiple selected reporting months
- **Behavior:** Supports single-month and multi-month selection, allowing the viewer to assess customer experience over a custom time window rather than across the full dataset

**Business use:**  
This slicer allows the viewer to move from full-period customer experience summaries to period-specific analysis. It is especially useful for checking whether review behavior, delay sensitivity, or dissatisfaction patterns remain stable over time or shift during specific phases of marketplace growth.

### 2.3 Year navigation buttons

- **Type:** Bookmark-based button group
- **Options shown:** `2016`, `2017`, `2018`, `All`
- **Purpose:** Provides a quick way to switch the page between major reporting windows without manually selecting months in the Reporting Period slicer
- **Behavior:** Each button applies a predefined bookmarked filter state for the selected year or the full available period

**Business use:**  
These buttons make it easier to compare customer experience patterns across major reporting periods at a glance. They are especially useful for moving quickly between early-stage, growth-stage, and full-period views without repeatedly adjusting the month-level slicer.

---

## 3. KPI cards

This page does not use KPI cards because its purpose is not headline summarization but **relationship analysis**. The key value of the page comes from showing how customer satisfaction changes across **delivery-delay severity**, **shopping periods**, and **revenue exposure**, which is better communicated through comparative visuals than through isolated top-line indicators. In other words, this page is designed to explain *why* customer experience changes, not simply to report a small set of standalone summary numbers.

---

## 4. Charts and Visuals

### 4.1 Review Score Distribution (% of Reviews)

- **Chart Type:** Column chart
- **Title:** Review Score Distribution (% of Reviews)
- **X-axis:** `order_review_final[review_stars]`
- **Y-axis:** Count of `order_review_final[review_id]`
- **Displayed Values:** [Review %](../reference/measures-and-calculated-columns.md#review-percent)
- **Visual-level Filters:**  
  - `order_review_final[review_stars]` is not blank
- **Used As:** Baseline customer satisfaction distribution showing how review scores are distributed across the marketplace

**Business Definition:**  
This chart shows the distribution of non-blank review scores from 1 to 5 stars, using the count of `review_id` as the underlying volume measure and [Review %](../reference/measures-and-calculated-columns.md#review-percent) as the displayed value label. It provides a high-level view of customer sentiment by showing whether reviews are concentrated in low, middle, or high score ranges.

**Documentation Notes:**

➡︎ Uses `order_review_final[review_stars]` on the x-axis to group reviews by star rating  
➡︎ Uses count of `order_review_final[review_id]` on the y-axis to show review volume in each score bucket  
➡︎ Uses [Review %](../reference/measures-and-calculated-columns.md#review-percent) as the displayed value label so each bar shows its share of the review distribution rather than only raw count  
➡︎ Applies a visual-level filter excluding blank review scores so only submitted ratings are included  
➡︎ Serves as the baseline sentiment visual for the page before dissatisfaction is linked to delivery-delay severity  
➡︎ Helps establish whether customer feedback is broadly positive, polarized, or concentrated at the high end of the scale  

**Interpretation Notes:**

* Taller bars indicate a larger number of reviews at that score level
* The displayed percentage labels show the share of total reviews represented by each star bucket
* A heavy concentration at 4–5 stars suggests generally positive customer sentiment
* Lower-score bars provide context for the share of customers with clearly negative experiences
* This chart is descriptive rather than diagnostic; later visuals on the page explain how delivery delay contributes to those review outcomes

---

### 4.2 Customer Dissatisfaction by Delivery Delay (Order-Level Perspective)

- **Chart Type:** Column chart
- **Title:** Customer Dissatisfaction by Delivery Delay (Order-Level Perspective)
- **Subtitle:** *As delivery performance improves → dissatisfaction decreases*
- **X-axis:** [`orders_final[Delay Bucket 4]`](../reference/measures-and-calculated-columns.md#delay-bucket-4)
- **Y-axis Measure:** [Low Review %](../reference/measures-and-calculated-columns.md#low-review-percent)
- **Visual-level Filters:**  
  - `orders_final[Delay Bucket 4]` is not blank  
  - `orders_final[order_status] = "delivered"`  
  - `orders_final[timeline_is_valid] = 1`
- **Used As:** Order-level dissatisfaction visual showing how the share of low reviews changes across delivery-delay severity groups

**Business Definition:**  
This chart shows the percentage of reviews classified as low reviews within each delivery-delay bucket, using [`orders_final[Delay Bucket 4]`](../reference/measures-and-calculated-columns.md#delay-bucket-4) as the grouping field and [Low Review %](../reference/measures-and-calculated-columns.md#low-review-) as the outcome metric. It is designed to show how customer dissatisfaction changes as delivery performance worsens.

**Documentation Notes:**

➡︎ Uses [`orders_final[Delay Bucket 4]`](../reference/measures-and-calculated-columns.md#delay-bucket-4) on the x-axis to group delivered orders into four delivery-outcome categories: `Severely Late (>3d)`, `Late (1–3d)`, `On-Time`, and `Early (≥3d early)`  
➡︎ Uses [Low Review %](../reference/measures-and-calculated-columns.md#low-review-percent) on the y-axis to measure the share of reviews flagged as low within each delay category  
➡︎ Applies a visual-level filter excluding blank delay buckets so only classified delivery outcomes are included  
➡︎ Applies additional visual-level filters restricting the chart to delivered orders with `timeline_is_valid = 1`  
➡︎ Uses the sort helper [`orders_final[Delay Bucket 4 Sort]`](../reference/measures-and-calculated-columns.md#delay-bucket-4-sort) so categories appear in business-logical severity order rather than alphabetical order  
➡︎ Serves as the clearest customer-experience linkage visual on the page by showing how dissatisfaction escalates as lateness becomes more severe  

**Interpretation Notes:**

* Higher bars indicate a larger share of low reviews and therefore stronger customer dissatisfaction
* The chart shows a strong monotonic pattern: dissatisfaction is highest for severely late orders and lowest for on-time or early deliveries
* This visual is order-level and customer-outcome focused, making it a direct bridge between logistics performance and satisfaction impact
* The early-delivery and on-time groups provide an operational baseline for comparison against late-delivery categories
* Because the chart uses a percentage outcome rather than raw review count, it is designed to compare severity effects rather than absolute review volume

---

### 4.3 Average Review Score by Delay Severity

- **Chart Type:** Column chart
- **Title:** Average Review Score by Delay Severity
- **X-axis:** [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category)
- **Y-axis Measure:** [Avg Review Score](../reference/measures-and-calculated-columns.md#avg-review-score)
- **Reference Line:** Overall average based on [Avg Review Score](../reference/measures-and-calculated-columns.md#avg-review-score)
- **Visual-level Filters:**  
  - `orders_final[Delay Category]` is not blank
- **Used As:** Satisfaction-severity visual showing how average customer rating changes across simplified delivery-delay categories

**Business Definition:**  
This chart compares the average review score across simplified delivery-delay categories using [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category) as the grouping field and [Avg Review Score](../reference/measures-and-calculated-columns.md#avg-review-score) as the outcome metric. It shows how overall customer sentiment deteriorates as delivery performance worsens.

**Documentation Notes:**

➡︎ Uses [`orders_final[Delay Category]`](../reference/measures-and-calculated-columns.md#delay-category) on the x-axis to group orders into `On-Time`, `Late (1–3d)`, and `Severely Late (>3d)` categories  
➡︎ Uses [Avg Review Score](../reference/measures-and-calculated-columns.md#avg-review-score) on the y-axis to measure average customer satisfaction within each delay group  
➡︎ Applies a visual-level filter excluding blank delay categories so only classified delivery outcomes are included  
➡︎ Includes a horizontal reference line based on [Avg Review Score](../reference/measures-and-calculated-columns.md#avg-review-score), providing a marketplace-wide benchmark for comparison  
➡︎ Complements the low-review chart by showing the continuous rating penalty associated with worsening delivery severity, not just the share of clearly dissatisfied customers  
➡︎ Makes visible that customer satisfaction declines sharply as lateness becomes more severe  

**Interpretation Notes:**

* Higher bars indicate stronger customer satisfaction on the 1-to-5 review scale
* Bars above the reference line are performing better than the overall average review score, while bars below it are underperforming
* The chart shows a clear downward gradient from `On-Time` to `Late (1–3d)` to `Severely Late (>3d)`
* This visual is useful because it captures the full average rating effect of delay severity, including moderate declines that may not appear in a binary low-review metric
* It should be interpreted together with the dissatisfaction chart to understand both the average rating penalty and the concentration of strongly negative reviews

---

### 4.4 Share of Low Reviews by Delivery Performance and Shopping Period

- **Chart Type:** Matrix / heatmap
- **Title:** Share of Low Reviews by Delivery Performance and Shopping Period
- **Rows:** `dim_shopping_period[Shopping Period]`
- **Columns:** `dim_delay_category[Delay Category]`
- **Values:** [Low Review %](../reference/measures-and-calculated-columns.md#low-review-percent)
- **Visual-level Filters:**  
  - `orders_final[Delay Category]` is not blank  
  - `orders_final[delivery_timestamp_is_complete] = 1`  
  - `orders_final[order_status] = "delivered"`
- **Used As:** Shopping-period sensitivity heatmap showing how customer dissatisfaction changes across both: delivery-performance severity and seasonal demand periods

**Business Definition:**  
This matrix shows the share of low reviews across combinations of shopping period and delivery-performance severity. It uses [Low Review %](../reference/measures-and-calculated-columns.md#low-review-percent) as the cell value, with shopping periods arranged on rows and simplified delay categories on columns. The goal is to identify whether certain commercial periods are more sensitive to poor delivery execution than others.

**Documentation Notes:**

➡︎ Uses `dim_shopping_period[Shopping Period]` on rows to compare major commercial periods such as Childrens Day, Christmas, Black November, and Regular periods  
➡︎ Uses `dim_delay_category[Delay Category]` on columns to compare `On-Time`, `Late (1–3d)`, and `Severely Late (>3d)` delivery outcomes  
➡︎ Uses [Low Review %](../reference/measures-and-calculated-columns.md#low-review-percent) as the matrix value, allowing each cell to express dissatisfaction as a comparable percentage rather than raw review count  
➡︎ Applies visual-level filters restricting the analysis to delivered orders with complete delivery timestamps and non-blank delay category classification  
➡︎ Shopping-period membership is assigned in [`orders_final[Shopping Period]`](../reference/measures-and-calculated-columns.md#shopping-period), while `dim_shopping_period` serves as the reporting dimension used to display those groups in a stable business-defined order  
➡︎ Uses custom sort logic from `dim_shopping_period[Sort Order]` and `dim_delay_category[Sort Order]` so both rows and columns appear in business-logical order rather than alphabetical order  
➡︎ Functions as the page’s core interaction heatmap by combining customer experience, delivery severity, and calendar sensitivity in one view  

**Interpretation Notes:**

* Darker red cells indicate a higher share of low reviews and therefore stronger customer dissatisfaction
* The matrix makes it easy to compare not only whether severe delays are damaging, but whether they are more damaging during certain shopping periods
* A strong gradient from `On-Time` to `Severely Late (>3d)` within a row indicates that customer sentiment is highly sensitive to delivery execution in that period
* Differences across rows show that some commercial periods appear more fragile than others even at similar delay levels
* Because the matrix uses a percentage measure, it is designed for behavioral comparison rather than order-volume comparison

---

### 4.5 Revenue at Risk: Value and Share by Delay Severity

- **Chart Type:** Line and clustered column chart
- **Title:** Revenue at Risk: Value and Share by Delay Severity
- **Subtitle:** *Bars show Net GMV from 1–2 star orders; the line shows its share within each delay category*
- **X-axis:** `dim_delay_category[Delay Category]`
- **Column Y-axis Measure:** [Revenue at Risk](../reference/measures-and-calculated-columns.md#revenue-at-risk)
- **Line Y-axis Measure:** [% Revenue at Risk](../reference/measures-and-calculated-columns.md#percent-revenue-at-risk)
- **Visual-level Filters:** None
- **Used As:** Combined value-and-share visual showing how much revenue is associated with low-rated orders across simplified delivery-delay categories

**Business Definition:**  
This chart compares both the **absolute value** and the **relative share** of revenue associated with dissatisfied orders across delay-severity groups. The columns show [Revenue at Risk](../reference/measures-and-calculated-columns.md#revenue-at-risk), defined as [`Net GMV`](../reference/measures-and-calculated-columns.md#net-gmv) from orders with review scores of 1 or 2 stars, while the line shows [`% Revenue at Risk`](../reference/measures-and-calculated-columns.md#percent-revenue-at-risk), indicating how large that at-risk portion is within each delay category.

**Documentation Notes:**

➡︎ Uses `dim_delay_category[Delay Category]` on the x-axis to compare `On-Time`, `Late (1–3d)`, and `Severely Late (>3d)` delivery outcomes  
➡︎ Uses [`Revenue at Risk`](../reference/measures-and-calculated-columns.md#revenue-at-risk) as the column measure to show the absolute amount of billed value tied to low-rated orders  
➡︎ Uses [`% Revenue at Risk`](../reference/measures-and-calculated-columns.md#percent-revenue-at-risk) as the line measure to show how concentrated dissatisfied-order revenue is within each delay category  
➡︎ Applies no visual-level filters, so the chart remains fully responsive to the page’s slicers and current report context  
➡︎ Combines magnitude and proportion in one visual, making it possible to distinguish where revenue at risk is large in absolute terms from where it is most severe as a share of category GMV  
➡︎ Uses the simplified delay-severity dimension from `dim_delay_category`, which is sorted through `dim_delay_category[Sort Order]` to preserve a business-logical progression from better to worse delivery outcomes  
➡︎ Extends the customer-experience story from ratings and dissatisfaction into commercial impact, showing that delay severity affects not only reviews but also the value exposed to poor customer outcomes  

**Interpretation Notes:**

* Taller blue bars indicate a larger absolute amount of revenue associated with low-rated orders
* Higher red line values indicate that dissatisfied-order revenue makes up a larger share of GMV within that delay category
* The chart can show high absolute revenue at risk in categories with large order volume, even when the share is relatively low
* It can also show smaller absolute revenue at risk in volume-light categories while still revealing a much higher concentration of commercial risk
* This makes the visual useful for separating exposure by scale from exposure by intensity

---

## 5. Page summary

**Main Insights:**

➡︎ The page shows that customer satisfaction is strongly tied to delivery performance, with dissatisfaction rising sharply as delay severity increases  
➡︎ Review distribution is heavily concentrated in 4- and 5-star ratings overall, but delay-based visuals show, that this positive pattern deteriorates quickly when orders arrive late  
➡︎ Severely late orders show the highest share of low reviews and the lowest average review scores, confirming that delivery failure is a major driver of negative customer sentiment
➡︎ Delivery delays do not hurt equally. Some periods amplify dissatisfaction dramatically  
➡︎ The shopping-period heatmap shows that some commercial periods are more sensitive to poor delivery execution than others, meaning identical delay severity does not always produce identical customer reactions  
➡︎ The revenue-at-risk view extends the satisfaction story into commercial impact by showing both the amount and the share of GMV associated with low-rated orders across delay categories  
➡︎ Together, the visuals show that **delivery delay is not only an operational issue, but also a customer-experience and revenue-risk issue**

**Why This Customer Experience Page Matters:**

➡︎ It gives decision-makers a direct view of how logistics performance translates into customer sentiment  
➡︎ It connects review behavior to delivery execution, making satisfaction outcomes more explainable rather than treating ratings as isolated feedback  
➡︎ It highlights that customer dissatisfaction is not uniform across shopping periods, which is important for understanding seasonal fragility in the marketplace  
➡︎ It adds a commercial lens to customer experience by showing where poor delivery performance puts revenue quality at risk  

---
