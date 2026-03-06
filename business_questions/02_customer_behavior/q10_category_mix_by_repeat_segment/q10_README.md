**Customer Behavior → Q10 Category Mix by Repeat Segment**

# Business Question 10 — Category Preferences of Repeat Customers

## Question

**How does GMV by product category differ between one-time, light-repeat, and heavy-repeat customers, and which categories are relatively more important for heavy-repeat customers?**

---

## Why This Matters

* Understanding category preferences across different levels of customer loyalty helps identify which product categories encourage repeat purchases.

* If specific categories consistently attract repeat buyers, Olist can focus its merchandising strategy, recommendation algorithms, and promotional efforts on these segments to increase long-term customer retention.

---

## Analytical Approach

To evaluate category affinity across different customer segments, transaction values were mapped to individual product categories and customer purchase frequency groups.

**Main datasets:**

- `order_items`
- `orders`
- `customers`
- `products`

**Key filters**

To ensure reliable results, the analysis was restricted to:

- delivered orders
- transactions with valid chronological timelines
- records excluding operational anomalies

**Derived metrics**

- **Item-level GMV** — calculated by distributing order-level payment value proportionally across individual order items.
- **Customer frequency segments**  
  > - **One-time buyers** — 1 order  
  > - **Light-repeat buyers** — 2 orders  
  > - **Heavy-repeat buyers** — 3 or more orders

**Granularity**

Product-category GMV share was calculated separately for each customer frequency segment.

---

## Analysis Implementation

Category-level revenue contributions were calculated in **R within the Kaggle notebook** using datasets cleaned and prepared in **Google BigQuery**.

Customer purchase frequency segments were combined with category-level GMV calculations to compare how spending patterns differ between one-time and repeat customers.

---

## Visualisations

<p align="center">
<img src="q10_dataviz/category_gmv_by_segment.png" width="700">
</p>

*Figure 10.1 — Top product categories by GMV share within each customer frequency segment, highlighting the stronger category concentration among heavy-repeat buyers.*

---

## Key Findings

**Core revenue drivers**: Across all segments, GMV is concentrated in a small group of lifestyle and consumer categories, including:   

> - **health_beauty**
> - **sports_leisure**
> - **fashion_bags_accessories**
> - **watches_gifts**

**Heavy-repeat category affinity**: Heavy-repeat customers show particularly strong concentration in:  

> - **bed_bath_table (≈15%)**  
> - **sports_leisure (≈10%)**  
> - **watches_gifts (≈10%)**  

**Segment differences**: While **health_beauty** dominates purchases among one-time buyers, its relative importance declines among repeat customers. In contrast, **bed_bath_table** becomes the primary category among heavy-repeat buyers.  

**Category-driven loyalty**: The concentration of spending among repeat buyers suggests that repeat behavior is often tied to **habitual purchases within specific product niches**.  

---

## Insight

➜ Repeat purchasing on Olist appears to be strongly linked to specific product categories, particularly those related to **home goods, sports, and lifestyle products**.

➜ The increasing importance of **bed_bath_table** and **sports_leisure** among heavy-repeat customers suggests that these categories encourage repeat engagement. By steering one-time buyers toward these high-loyalty categories through cross-selling and personalized recommendations, Olist could meaningfully increase its repeat purchase rate.

---

➡️ **Next:** [Q11 Delivery Speed vs Repeat Rate](../../03_operations_and_logistics/q11_delivery_speed_vs_repeat_rate/q11_README.md)