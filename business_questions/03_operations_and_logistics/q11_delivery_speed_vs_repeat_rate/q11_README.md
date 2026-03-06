**Operations & Logistics → Q11 Delivery Speed vs Repeat Rate**

# Business Question 11 — Delivery Speed and Customer Loyalty

## Question

**How do delivery times and delays differ between one-time, light-repeat, and heavy-repeat customers, and is faster, more reliable delivery associated with higher repeat purchase behaviour?**

---

## Why This Matters

Delivery speed is often assumed to be a key driver of customer loyalty in e-commerce. If faster delivery significantly increases the likelihood of repeat purchases, Olist could justify aggressive investments in high-speed logistics infrastructure.

However, if delivery performance is similar across all customer segments, it suggests that other factors—such as product variety, pricing, or category preference—may play a larger role in encouraging repeat purchases.

---

## Analytical Approach

To investigate the relationship between logistics performance and customer loyalty, the analysis compared delivery outcomes across different customer frequency segments.

**Main datasets**

- `orders_enriched`
- `order_items`
- `customer_segments`

**Key filters**

The analysis was restricted to **delivered orders with valid chronological timelines** to ensure that delivery performance metrics reflect completed transactions.

**Derived metrics:**

- **delivery_performance** — a four-tier classification based on category-specific benchmarks:  
  > - **1 = Fast**  
  > - **2 = Typical**  
  > - **3 = Slow**  
  > - **4 = Very Slow**

**Customer segmentation:**

Customers were grouped into:

> - **One-time buyers** — 1 order  
> - **Light-repeat buyers** — 2 orders  
> - **Heavy-repeat buyers** — 3 or more orders

**Granularity:** Delivery performance was evaluated using:  

- **Average delivery days per segment**
- **Share of orders across performance tiers**

---

## Analysis Implementation

Delivery performance metrics were calculated in **R within the Kaggle notebook** using datasets cleaned and prepared in **Google BigQuery**.

Orders were classified into delivery performance tiers and compared across customer segments to determine whether faster shipping correlates with repeat purchasing behaviour.

---

## Visualisations

<p align="center">
<img src="q11_dataviz/avg_delivery_days_by_segment.png" width="700">
</p>

*Figure 11.1 — Average delivery days by customer segment, showing that delivery time from purchase to receipt does not significantly decrease for more loyal customers.*

<p align="center">
<img src="q11_dataviz/delivery_performance_by_segment.png" width="700">
</p>

*Figure 11.2 — Delivery performance mix by customer segment, demonstrating that the distribution of delivery speeds remains remarkably consistent regardless of customer loyalty.*

---

## Key Findings

**Consistent delivery experience**

Delivery performance is remarkably similar across all customer segments, with only marginal differences between one-time and repeat buyers.

**Stable distribution**

Across segments, approximately:

- **~50%** of orders fall into the **Typical** delivery range  
- **~27–29%** of orders are classified as **Fast**

**Tolerance for delays**

Heavy-repeat customers still experience slower deliveries in a meaningful share of transactions, with **19% of their orders classified as Slow or Very Slow**.

**Minimal advantage**

One-time buyers have a slightly higher share of **Very Slow** deliveries (6.2%) compared with heavy-repeat customers (4.6%), but the difference is too small to suggest that delivery speed drives repeat behaviour.

---

## Insight

The results suggest that **delivery speed alone is not a primary driver of customer loyalty on the Olist platform**. Loyal customers experience delivery performance patterns that are broadly similar to those of one-time buyers.

This indicates that repeat purchasing behaviour is more likely influenced by **product category preferences, pricing, or perceived product value** rather than logistics performance.

While reducing slow deliveries remains important for protecting overall customer satisfaction, **merchandising strategy and personalized offers may represent more effective levers for improving customer retention**.

---

➡️ **Next:** [Q12 Reviews vs Repeat Rate](../q12_reviews_vs_repeat_rate)