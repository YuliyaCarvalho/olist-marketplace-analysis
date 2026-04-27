**Operations & Logistics → q11 Delivery Speed vs Repeat Rate/Customer Loyalty**

# Business Question 11 — Delivery Speed and Customer Loyalty

## Question

**How do delivery times and delays differ between one-time, light-repeat, and heavy-repeat customers, and do repeat customers experience systematically different delivery performance compared to one-time buyers?**

---

## Why This Matters

This analysis evaluates whether **logistics performance acts as a catalyst for customer loyalty**.
Delivery speed is often assumed to be a key driver of customer loyalty in e-commerce. If repeat customers systematically experience better delivery performance, Olist could justify aggressive investments in high-speed logistics infrastructure.

However, if delivery performance is similar across all customer segments, it suggests that other factors—such as product variety, pricing, or category preference—may play a larger role in encouraging repeat purchases.

Understanding the role of logistics in retention helps determine whether operational investments in delivery speed would meaningfully improve customer lifetime value.


---

## Analytical Approach

To investigate the relationship between logistics performance and customer loyalty, the analysis compared delivery outcomes across different customer frequency segments.

**Main datasets**

- `delivered_orders`
- `order_items`


**Key filters**

The analysis was restricted to **delivered orders with valid chronological timelines** and **non-hanging orders** to ensure that delivery performance metrics reflect completed and internally consistent transactions.

Because `delivery_performance` was benchmarked relative to **product-category-specific delivery norms**, a small number of **multi-item, multi-category orders** could map to more than one delivery-performance class. To preserve a single unambiguous delivery-performance label per order, the final comparison was restricted to **single-item delivered clean orders only**.

This restriction retained the large majority of the cohort:

- **95082** delivered clean orders in total
- **85606** single-item delivered clean orders retained
- **9476** multi-item orders excluded
- **90.03%** of the delivered clean-order cohort preserved

**Derived metrics:**

**delivery_performance** — a four-tier classification based on category-specific benchmarks:  
  > - **1 = Fast**  
  > - **2 = Typical**  
  > - **3 = Slow**  
  > - **4 = Very Slow**

**Customer frequency segments:** Customers were classified based on their order history:
> - **One-time buyers** — 1 order  
> - **Light-repeat buyers** — 2 orders  
> - **Heavy-repeat buyers** — 3 or more orders

**Delivery performance metric:** Delivery speed was categorized using **category-specific percentile benchmarks**:

| Performance Tier | Definition |
|---|---|
| Fast | ≤ P25 delivery time |
| Typical | P25–P75 |
| Slow | P75–P95 |
| Very Slow | > P95 |

This normalization ensures fair comparisons across product categories with different logistical characteristics.

**Aggregation level:** The analysis measures the **share of single-item delivered clean orders within each delivery performance tier for every customer segment**.

**Granularity:** Delivery performance was evaluated using:  
> - **Average delivery days per segment**
> - **Share of orders across performance tiers**

---

## Analysis Implementation

Delivery performance metrics were calculated in **R within the Kaggle notebook** using datasets cleaned and prepared in **Google BigQuery**.

Orders were classified into delivery performance tiers and compared across customer segments to determine whether faster shipping correlates with repeat purchasing behaviour.

---

## Visualisations

<p align="center">
<img src="q11_dataviz/delivery_mix_segments.png" width="800">
</p>

*Figure 11.1 — Delivery performance mix by customer segment for **single-item delivered clean orders only**, showing that the distribution of category-relative delivery speeds remains broadly consistent across different customer loyalty levels*

<p align="center">
<img src="q11_dataviz/delivery_friction_rate.png" width="800">
</p>

*Figure 11.2 — Delivery friction rate by customer segment for **single-item delivered clean orders only**, comparing the share of better delivery experiences (Fast + Typical) versus slower delivery experiences (Slow + Very Slow).*

---


## Key Findings

* **Broadly consistent delivery mix:** Delivery performance is highly similar across customer segments. In all three groups:  
> - about **46–51%** of orders fall into the **Typical** range  
> - about **26–28%** are classified as **Fast**  
> - about **17–20%** are classified as **Slow**  
> - about **6%** are **Very Slow**

This indicates that delivery performance among retained customers is broadly similar across segments.

* **No meaningful fast-delivery advantage for repeat buyers:** Heavy-repeat customers do **not** show a materially higher share of **Fast** deliveries than one-time buyers.  
> - **Fast:** 27.75% for one-time vs **25.91%** for heavy-repeat  
> - **Typical:** 46.96% for one-time vs **51.19%** for heavy-repeat  

The slight advantage for heavy-repeat customers comes mainly from a somewhat higher share of **Typical** deliveries, not from a strong increase in exceptionally fast fulfillment.

* **Slightly lower delivery friction among heavy-repeat buyers:** When delivery performance is collapsed into broader groups:  
> - **One-time:** **75%** better delivery vs **25%** slower delivery  
> - **Light-repeat:** **74%** better delivery vs **26%** slower delivery  
> - **Heavy-repeat:** **77%** better delivery vs **23%** slower delivery  

This suggests a **modest** logistics advantage for heavy-repeat customers, but the gap is small.

* **Poorer delivery outcomes still exist among loyal customers:** Even among heavy-repeat customers:  
> - **17.17%** of orders are classified as **Slow**  
> - **5.72%** are **Very Slow**  

Together, that means **22.89%** of heavy-repeat orders still fall into the slower-delivery tiers. Loyal customers therefore continue purchasing even when delivery performance is not ideal.

* **Differences are directionally interesting, but not large enough to explain loyalty on their own:** One-time buyers experience a somewhat higher share of poorer delivery outcomes than heavy-repeat customers, but the gap remains modest.  
> - **Very Slow:** 6.54% for one-time vs **5.72%** for heavy-repeat  
> - **Slow + Very Slow:** 25% for one-time vs **23%** for heavy-repeat  

These differences are too small to support the idea that logistics speed is the primary driver of repeat purchasing behaviour.

---

## Insight

➜ Delivery speed and category-relative delivery performance do **do not show strong differentiation across customer segments on the Olist platform**.

➜ Heavy-repeat customers do show a **slightly cleaner delivery profile**, mainly through a somewhat lower share of slower delivery outcomes, but the differences are modest.

➜ Because delivery performance remains broadly similar across one-time, light-repeat, and heavy-repeat customers, repeat purchasing is likely influenced more strongly by other factors such as:

- product assortment
- category affinity
- pricing competitiveness
- purchase intent tied to specific product types

➜ Logistics performance still matters for overall customer experience, but the evidence here suggests that improving delivery speed alone would probably not generate a large increase in repeat purchasing. The stronger levers are more likely to lie in **merchandising, product discovery, and targeted retention strategies**, rather than purely operational acceleration.

➜ The analysis is descriptive and does not establish causality; repeat behaviour may be influenced by prior experiences not captured in this comparison.

---

## Next Question

➡️ **Next:** If delivery speed isn't the primary differentiator for loyalty, the next step is to examine subjective satisfaction: "How do customer review scores differ between one‑time, light‑repeat, and heavy‑repeat customers, and are higher review scores associated with higher repeat‑purchase behaviour?"
[q12 Reviews vs Repeat Rate](../../04_customer_value_and_risk/q12_reviews_vs_repeat_rate/q12_README.md)

