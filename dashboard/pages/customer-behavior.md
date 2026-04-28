# Olist Dashboard — Customer Behavior Overview

**Business Context:** *Core Question: How do customers buy, return, and contribute value over time?*  
This page explains the behavioral side of the marketplace. It focuses on customer purchase frequency, repeat buying, revenue concentration, and regional differences in customer value. The goal is to show whether growth is driven mostly by broad customer participation or by a smaller group of higher-value repeat buyers.

## 1. Report page purpose

- **Page Role:** Customer behavior and value analysis
- **Primary Objective:** Evaluate customer retention, purchase frequency, repeat-customer value, revenue concentration, and geographic variation in customer spend
- **Grain of Analysis:** Primarily customer-level, supported by order-level and region-level aggregations

**Key Business Questions:**

- How many customers place only one order versus returning to buy again?
- What share of the customer base is repeat versus one-time?
- How much revenue comes from repeat customers?
- How concentrated is marketplace value among the highest-spending customers?
- How does customer value vary across regions?
- Is repeat customer behavior improving over time?

---

## 2. Page-level filters and navigation controls

This page includes two slicers and one bookmark-based year selector, that together control the reporting window and geographic customer segment being analyzed. These controls are designed to let the viewer move between broad marketplace patterns and narrower behavioral slices without changing the logic of the page.

### 2.1 Customer Region slicer

- **Field used:** `customers_final[Customer Region]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the entire page to customers belonging to a selected Brazilian macro-region
- **Behavior:** Allows the viewer to isolate customer behavior patterns by region, including customer mix, repeat behavior, customer value, and revenue concentration

**Business use:**  
This slicer answers whether customer behavior differs structurally by geography. It helps test questions such as whether some regions have higher customer value, stronger repeat behavior, or a different customer mix than others.

### 2.2 Reporting Period slicer

- **Field used:** `dim_date[YearMonth Label]`
- **Type:** Dropdown slicer
- **Purpose:** Filters the page to one or multiple selected reporting months
- **Behavior:** Supports single-month and multi-month selection, making it possible to analyze customer behavior over a custom time window rather than the full dataset

**Business use:**  
This slicer allows the viewer to move from full-period summaries to period-specific behavior. It is especially useful for checking whether repeat buying, customer value, or segment mix changes across different months or phases of marketplace growth.

### 2.3 Year bookmark buttons

- **Controls shown:** `2016`, `2017`, `2018`, `All`
- **Type:** Bookmark buttons
- **Purpose:** Provide fast preset time selections without manually choosing months in the Reporting Period slicer
- **Behavior:** Each button applies a predefined month selection in the `Reporting Period` slicer:
  - `2016` = months in 2016
  - `2017` = months in 2017
  - `2018` = months in 2018
  - `All` = full available reporting period

**Business use:**  
These buttons improve usability and speed. Instead of manually selecting multiple months, the viewer can instantly switch between yearly views and the full-period view. This makes period comparisons more efficient and reduces slicer friction during dashboard navigation.

### Filter design note

These controls are page-wide and affect all visuals unless a visual has been explicitly configured otherwise. Together, they allow the page to support both:
- **broad behavioral analysis** across the full customer base, and
- **focused analysis** by region and time period

---

## 3. KPI cards

### 3.1 Customers with Valid Orders

- **Display Name:** Customers with Valid Orders
- **Type:** Card
- **Measure:** [Valid Customers](./olist-dashboard-measures-and-calculated-columns.md#valid-customers)
- **Used As:** Headline count of distinct customers with at least one valid delivered order

**Business Definition:**  
Represents the number of unique customers who placed at least one order that qualifies as a **valid delivered order**, meaning the order was delivered, passed timeline quality checks, was not flagged as hanging, and had `payment_value >= 1`.

**Documentation Notes:**

➡︎ This is the baseline customer-size KPI for the page  
➡︎ It uses a cleaned commercial cohort rather than all historical customers  
➡︎ Each customer is counted only once, regardless of how many valid orders they placed  

---

### 3.2 Lifetime Repeat Customer Rate

- **Display Name:** Lifetime Repeat Customer Rate
- **Type:** Card
- **Measure:** [Lifetime Repeat Customer Rate](./olist-dashboard-measures-and-calculated-columns.md#lifetime-repeat-customer-rate)
- **Used As:** Headline retention KPI showing the share of valid customers who purchased more than once across their full observed lifetime

**Business Definition:**  
Represents the percentage of **lifetime valid customers** who placed more than one **valid delivered order** across the full available dataset.

**Documentation Notes:**

➡︎ This is a **lifetime** customer metric, not a period-specific repeat rate  
➡︎ Both numerator and denominator remove the date filter using `ALL(dim_date)`  
➡︎ A customer is classified as repeat only if they placed **more than one** valid delivered order across their full history  
➡︎ The metric still responds to non-date filters, such as `Customer Region`, but not to the selected reporting period  

---

### 3.3 Avg Orders per Customer

- **Display Name:** Avg Orders per Customer
- **Type:** Card
- **Measure:** [Average Orders per Customer](./olist-dashboard-measures-and-calculated-columns.md#average-orders-per-customer)
- **Used As:** Headline frequency KPI showing the average number of valid delivered orders per valid customer

**Business Definition:**  
Represents the average number of **valid delivered orders** placed per **valid customer** in the current filter context.

**Documentation Notes:**

➡︎ Calculated as `Valid Delivered Orders ÷ Valid Customers`  
➡︎ Uses the same cleaned valid-order cohort as the rest of the page  
➡︎ Interprets customer activity as average purchase frequency, not customer lifetime status  
➡︎ Responds to both time and region filters because neither supporting measure removes page context  

---

### 3.4 AOV

- **Display Name:** AOV
- **Type:** Card
- **Measure:** [AOV](./olist-dashboard-measures-and-calculated-columns.md#aov)
- **Used As:** Headline order-value KPI showing the average net value generated per valid delivered order

**Business Definition:**  
Represents the average **Net GMV** generated per **valid delivered order** in the current filter context.

**Documentation Notes:**

➡︎ Calculated as `Net GMV ÷ Valid Delivered Orders`  
➡︎ This is the true order-level **Average Order Value** metric  
➡︎ Uses cleaned net revenue and the valid delivered order cohort  
➡︎ Responds to both time and region filters through its supporting measures  

---

### 3.5 Net GMV per Customer

- **Display Name:** Net GMV per Customer
- **Type:** Card
- **Measure:** [GMV per Customer](./olist-dashboard-measures-and-calculated-columns.md#gmv-per-customer)
- **Used As:** Headline customer-value KPI showing the average net marketplace value generated per valid customer

**Business Definition:**  
Represents the average **Net GMV** generated per **valid customer** in the current filter context.

**Documentation Notes:**

➡︎ Calculated as `Net GMV ÷ Valid Customers`  
➡︎ Uses cleaned net revenue rather than gross billed value  
➡︎ Measures average customer value at the customer level, not average order size  
➡︎ Responds to both time and region filters through its supporting measures  

---

### 3.6 Revenue from Repeat Customers %

- **Display Name:** Revenue from Repeat Customers %
- **Type:** Card
- **Measure:** [Revenue from Repeat Customers %](./olist-dashboard-measures-and-calculated-columns.md#revenue-from-repeat-customers-percent)
- **Used As:** Headline retention-value KPI showing the share of net revenue generated by repeat customers

**Business Definition:**  
Represents the percentage of total `Net GMV` generated by customers classified as repeat buyers rather than one-time buyers.

**Documentation Notes:**

➡︎ Calculated as `Repeat Customer GMV ÷ Net GMV`  
➡︎ Uses customer frequency segmentation to isolate revenue contributed by repeat buyers  
➡︎ Excludes customers classified as `One-time buyers` from the numerator  
➡︎ Interpretation depends on how customer segments are defined in the `customer_frequency` table  

---

### 3.7 Top 10% Customers GMV Share

- **Display Name:** Top 10% Customers GMV Share
- **Type:** Card
- **Measure:** [Top 10% Customers GMV Share](./olist-dashboard-measures-and-calculated-columns.md#top-10-percent-customers-gmv-share)
- **Used As:** Headline revenue-concentration KPI showing how much of total net revenue is generated by the highest-value 10% of customers

**Business Definition:**  
Represents the share of total `Net GMV` contributed by the top 10% of customers ranked by customer-level `Net GMV` in the current filter context.

**Documentation Notes:**

➡︎ Builds a customer-level ranking based on `Net GMV` per customer  
➡︎ Selects the top 10% of customers by value, rounded up to the nearest whole customer  
➡︎ Calculates how much of total `Net GMV` is generated by that top customer group  
➡︎ Used to show revenue concentration and customer-value skew  

---

### 3.8 Top 10% Customer Count

- **Display Name:** Top 10% Customer Count
- **Type:** Card
- **Measure:** [Top 10% Customer Count](./olist-dashboard-measures-and-calculated-columns.md#top-10-percent-customer-count)
- **Used As:** Supporting concentration KPI showing how many customers are included in the top-value 10% group

**Business Definition:**  
Represents the number of customers included in the top 10% customer cohort within the current filter context.

**Documentation Notes:**

➡︎ Counts distinct customers in the current context  
➡︎ Multiplies that customer base by 10% and rounds up to the nearest whole customer  
➡︎ Ensures at least 1 customer is returned, even in very small filtered populations  
➡︎ Used to make the concentration metric more interpretable in absolute terms  

---

**3.7 + 3.8 Interpretation:**  
The top 10% of customers account for **38.29% of total Net GMV**, indicating a clear, but not extreme concentration of customer value. Revenue is meaningfully skewed toward a relatively small high-value customer group, yet the majority still comes from the broader customer base. This suggests that the marketplace benefits from both: **broad customer participation** and a **distinct high-value segment**, without being overly dependent on a narrow set of top spenders. 
**Insight: Although the customer base is dominated by one-time buyers, Net GMV is not evenly distributed: the top 10% of customers account for over a third (39.13%) of revenue**

---

## Charts and Visuals

### 4.1 Customer Purchase Frequency

- **Display Name:** Customer Purchase Frequency
- **Type:** Horizontal bar chart
- **Axis:** `Customer Segment Table[Customer Segment]`
- **Measure:** [Customer Share %](./olist-dashboard-measures-and-calculated-columns.md#customer-share-percent)
- **Used As:** Segment mix view showing how the valid customer base is distributed across purchase-frequency groups

**Business Definition:**  
Shows the percentage share of customers belonging to each purchase-frequency segment: **One-time Buyers**, **Light Repeat Buyers**, and **Heavy Repeat Buyers**.

**How to Read It:**  
Each bar represents the share of the valid customer base assigned to a given segment. Together, the three bars show whether the marketplace is primarily driven by single-purchase customers or supported by a broader repeat-customer base.

**Documentation Notes:**

➡︎ Uses a dedicated disconnected segment table to control the display order and segment labels  
➡︎ The displayed value is selected dynamically through `Customer Share %` based on the active segment label  
➡︎ Segment shares are mutually exclusive and collectively describe the composition of the customer base  
➡︎ Best interpreted together with the revenue and customer-value charts below, since customer share does not by itself show commercial importance  
➡︎ **Segmentation scope:** customer segments in this visual are assigned using each customer’s **overall purchase frequency from `orders_final`**, based on total distinct orders per customer. They are therefore **not restricted to the narrower valid-order cohort** used in measures such as Net GMV or Valid Customers. This chart should be read as a view of the marketplace’s **broad buyer composition**, not as a segmentation of only customers with valid delivered paid orders.

**Business Interpretation:**  
This visual answers whether the marketplace has a broad repeat-customer foundation or remains dominated by one-time buyers. A highly skewed distribution toward one-time buyers suggests weak retention depth, even if total customer reach is large.

---

### 4.2 Revenue Contribution by Customer Segment

- **Display Name:** Revenue Contribution by Customer Segment
- **Type:** Horizontal bar chart
- **Axis:** [`orders_final[Customer Segment]`](./olist-dashboard-measures-and-calculated-columns.md#orders-final-customer-segment)
- **Measure:** [Net GMV](./olist-dashboard-measures-and-calculated-columns.md#net-gmv)
- **Used As:** Customer-segment revenue mix view showing how total net marketplace value is distributed across purchase-frequency groups

**Business Definition:**  
Shows the total `Net GMV` generated by each customer purchase-frequency segment: **One-time Buyers**, **Light Repeat Buyers**, and **Heavy Repeat Buyers**.

**How to Read It:**  
Each bar represents the total cleaned net revenue contributed by one customer segment in the current filter context. The chart shows whether marketplace value is driven mainly by broad one-time demand or by customers who return and purchase again.

**Documentation Notes:**

➡︎ Uses `orders_final[Customer Segment]` to split revenue by customer purchase-frequency group  
➡︎ Uses `Net GMV` as the value measure, so revenue is restricted to the cleaned valid-order cohort  
➡︎ Displays absolute contribution, not percentage share  
➡︎ Best interpreted together with the purchase-frequency and average-GMV charts, since a segment may be large in customer count but not necessarily dominant in customer value  

**Business Interpretation:**  
This visual shows which customer segments generate the most marketplace value. A large revenue contribution from **One-time Buyers** suggests that overall sales rely heavily on broad acquisition, while a stronger contribution from repeat segments would point to deeper customer retention and stronger lifetime value dynamics.

---

### 4.3 Average GMV by Customer Segment

- **Display Name:** Average GMV by Customer Segment
- **Type:** Horizontal bar chart
- **Axis:** `orders_final[Customer Segment]`
- **Measure:** [GMV per Customer](./olist-dashboard-measures-and-calculated-columns.md#gmv-per-customer)
- **Used As:** Customer-segment value view showing the average net marketplace value generated per customer within each purchase-frequency group

**Business Definition:**  
Shows the average `Net GMV` generated per **valid customer** for each customer purchase-frequency segment: **One-time Buyers**, **Light Repeat Buyers**, and **Heavy Repeat Buyers**.

**How to Read It:**  
Each bar represents average customer value within a segment, not total segment revenue. The chart highlights whether repeat customers are simply more numerous in revenue contribution or whether they are also individually more valuable.

**Documentation Notes:**

➡︎ Uses `orders_final[Customer Segment]` to split customers into purchase-frequency groups  
➡︎ Uses `GMV per Customer` as the value measure, calculated as `Net GMV ÷ Valid Customers`  
➡︎ Shows customer-level monetization rather than total segment contribution  
➡︎ Best interpreted together with the revenue-contribution chart, since a segment can be small in size but high in value per customer  

**Business Interpretation:**  
This visual shows the economic value of each customer segment on a per-customer basis. Higher values among repeat segments indicate that customers who return do not just buy more often, but also generate meaningfully greater value over time. That makes repeat behavior commercially important even when repeat buyers represent a small share of the total customer base.

---

### 4.4 Returning Customer Rate Over Time

- **Display Name:** Returning Customer Rate Over Time
- **Type:** Line chart
- **Axis:** `dim_date[Month Start]`
- **Measure:** [Returning Customer Rate](./olist-dashboard-measures-and-calculated-columns.md#returning-customer-rate)
- **Used As:** Trend view showing how the share of returning customers evolves over time

**Business Definition:**  
Shows the percentage of **valid customers** in each month who had already made at least one prior purchase before that month, allowing repeat customer momentum to be tracked over time.

**How to Read It:**  
Each point represents the share of monthly valid customers who are classified as returning rather than first-time in that month. Rising values indicate that a larger portion of the active monthly customer base is made up of previously acquired customers.

**Documentation Notes:**

➡︎ Calculated as `Returning Customers ÷ Valid Customers`  
➡︎ A customer is counted as returning if their earliest recorded purchase date is earlier than the current month being evaluated  
➡︎ The numerator uses the same cleaned valid-order cohort as the rest of the page: delivered orders only, `timeline_is_valid = 1`, `is_hanging = 0`, and `payment_value >= 1`  
➡︎ Data labels are shown only for selected months via `Returning Customer Rate Label` to reduce visual clutter  
➡︎ The visual timeline is intentionally limited to **Jan 2017 – Aug 2018**  

**Business Interpretation:**  
This visual shows whether the marketplace is building a stronger base of returning customers over time. An upward trend suggests improving customer re-engagement and growing retention depth, while flat or declining values would indicate continued dependence on first-time acquisition.

---

### 4.5 Average GMV per Customer by Region

- **Display Name:** Average GMV per Customer by Region
- **Type:** Column chart
- **Axis:** `customers_final[Customer Region]`
- **Measure:** [GMV per Customer](./olist-dashboard-measures-and-calculated-columns.md#gmv-per-customer)
- **Tooltip:** [Valid Customers](./olist-dashboard-measures-and-calculated-columns.md#valid-customers)
- **Used As:** Regional customer-value comparison showing how average net marketplace value per valid customer differs across Brazilian macro-regions

**Business Definition:**  
Shows the average `Net GMV` generated per **valid customer** in each customer region.

**How to Read It:**  
Each bar represents the average customer-level value within a region, calculated as `Net GMV ÷ Valid Customers`. Higher bars indicate that customers in that region generate more marketplace value on average.

**Documentation Notes:**

➡︎ Uses `customers_final[Customer Region]` to compare customer value across Brazilian macro-regions  
➡︎ Uses `GMV per Customer` as the main metric, so the visual reflects average customer monetization rather than total regional revenue  
➡︎ Tooltip displays `Valid Customers`, `AOV`, and `Valid Delivered Orders` to provide regional customer-base, order-value, and order-volume context behind the averages    
➡︎ Best interpreted together with customer volume and retention metrics, since a high average can still come from a relatively small customer base  

**Business Interpretation:**  
This visual shows whether customer value differs meaningfully by geography. Higher-value regions may indicate stronger purchasing power, larger basket behavior, or a more commercially valuable customer mix, while lower-value regions may reflect smaller average spend even if customer reach is broad.

---














## Cards

### Top 10% Customers GMV Share + Top 10% Customer Count

> * Top 10% share of Net GMV: 39.13%  
> * Customers with valid orders: 92K  
> * Top 10% customers: 9.61K 

Customer base is not evenly monetized, but it is also not hyper-concentrated.

If revenue were perfectly even, top 10% customers would generate about 10% of GMV. In Olist dataset it's 39.13%, so the top decile generates about 3.9x what an even distribution would imply.
That is a real concentration signal.

But: 
- it does not mean the business depends on a tiny elite  
- it does mean high-value customers materially outperform the average customer  



Given your existing charts, this card works well because it complements them:

your segment charts show who buys how often
this card shows how concentrated the money is

A clean insight line for the dashboard:

The top 10% of customers (9.61K out of 92K) generate 39.13% of Net GMV, indicating meaningful revenue concentration among high-value buyers.

If you want a slightly sharper version:

---


