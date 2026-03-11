**Customer Behavior → q10 GMV by Category & Customer Segment**

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

**Customer segmentation**: Customers were grouped according to their purchase frequency:

- **One-time** → 1 order  
- **Light-repeat** → 2 orders  
- **Heavy-repeat** → 3+ orders

**Key filters:** To ensure reliable results, the analysis was restricted to:
> - delivered orders
> - transactions with valid chronological timelines
> - records excluding operational anomalies


**Derived metrics:**

* **Proportional Item GMV** ➜ Because a single order can contain items from multiple categories, total order GMV was allocated to individual items **proportionally by item price**:
`Proportional Item GMV: gmv_item = gmv_order x (item_price / total_order_price)`
This ensures that revenue is correctly distributed across product categories.

* **Category GMV Share** ➜ For each customer segment: `GMV share = category GMV / total GMV of that segment`
This allows direct comparison of category importance across segments.

* **Validation** ➜ To prevent metric inflation, item-level allocations were validated to confirm that: `Σ item GMV = order GMV`
This ensures that revenue remains consistent between order-level and item-level analysis.

**Granularity** ➜ Product-category GMV share was calculated separately for each customer frequency segment.

---

## Analysis Implementation

Category-level revenue contributions were calculated in **R within the Kaggle notebook** using datasets cleaned and prepared in **Google BigQuery**.

Customer purchase frequency segments were combined with category-level GMV calculations to compare how spending patterns differ between one-time and repeat customers.

---

## Visualisations

*Only the top five categories by GMV share are displayed in the chart to improve readability; the remaining long-tail categories are omitted*
<p align="center">
<img src="q10_dataviz/top_categories_segment.png" width="800">
</p>

*Figure 10.1 — Top product categories by GMV share within each customer frequency segment, illustrating how heavy-repeat buyers concentrate spending in specific lifestyle categories.*

---

## Key Findings

* **Core revenue drivers:** Across all segments, GMV is concentrated in a small group of lifestyle and consumer categories, including:   
> - **health_beauty**
> - **sports_leisure**
> - **fashion_bags_accessories**
> - **watches_gifts**

* **Heavy-repeat category affinity:** Heavy-repeat customers show particularly strong concentration in:  
> - **bed_bath_table (~15%)**  
> - **sports_leisure (~10%)**  
> - **watches_gifts (~10%)**  

* **Segment differences:** While **health_beauty** dominates purchases among one-time buyers, its relative importance declines among repeat customers. In contrast, **bed_bath_table** becomes the primary category among heavy-repeat buyers.  

* **Category-driven loyalty:** The concentration of spending among repeat buyers suggests that repeat behavior is often tied to **habitual purchases within specific product niches**.  

---

## Insight

➜ Repeat purchasing on Olist is **not random**, it appears to be strongly linked to specific product categories - a small set of lifestyle and home categories.

➜ The share of **bed_bath_table** nearly doubles as customers move from their first purchase (~8%) to heavy-repeat status (~15%).  
This pattern suggests that certain categories naturally encourage **habitual or multi-item purchasing behaviour**.

From a strategic perspective, Olist could improve its repeat purchase rate by:

- directing first-time buyers toward high-loyalty categories
- implementing category-based recommendation engines
- introducing targeted cross-sell campaigns early in the customer lifecycle

---

## Next Question

➡️ **Next:** Having established what these loyal customers are buying, the next logical step is to see if their loyalty is earned through superior service: "How do delivery times and delays differ between one‑time, light‑repeat, and heavy‑repeat customers, and is faster, more reliable delivery associated with higher repeat purchase behaviour?"
[q11 Delivery Speed vs Repeat Rate](../../03_operations_and_logistics/q11_delivery_speed_vs_repeat_rate/q11_README.md)


