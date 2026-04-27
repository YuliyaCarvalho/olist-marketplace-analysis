**Customer Value & Risk → q12 Review Scores & Customer Loyalty**

# Business Question 12 — Customer Satisfaction and Repeat Purchasing

## Question

**How do customer review scores differ between one-time, light-repeat, and heavy-repeat customers, and are higher review scores associated with higher repeat-purchase behaviour?**

---

## Why This Matters

Customer reviews provide a direct signal of **subjective satisfaction with the purchasing experience**. Understanding how satisfaction differs across customer segments helps determine whether loyalty emerges from consistently positive experiences or whether loyal customers simply become more tolerant over time.

If highly satisfied customers are more likely to return, improving the experience of **first-time buyers** could become a powerful lever for increasing customer lifetime value and long-term marketplace growth.

---

## Analytical Approach

To evaluate the relationship between satisfaction and loyalty, customer review data was linked to behavioral segments using a unified customer identifier.

**Main datasets used**

- `order_reviews`
- `delivered_order_items`


**Customer frequency segments:** Customers were categorized according to their purchasing history:

- **One-time** → 1 order  
- **Light-repeat** → 2 orders  
- **Heavy-repeat** → 3+ orders  

**Key metrics**

**Review Distribution:** For each customer segment, the share of reviews was calculated across normalized rating categories:
> - excellent  
> - good  
> - neutral  
> - bad  
> - very bad  

This metric reveals how sentiment changes as customers become more loyal.

**Seller Response Time:** The variable `review_to_answer` measures the time between when a customer submits a review and when the seller responds. This was analyzed to determine whether sellers react differently to positive versus negative feedback.

**Customer Attribution Logic:** Reviews were linked to behavioral segments using `customer_unique_id`, ensuring that multiple orders from the same customer were assigned to the correct loyalty category.

---

## Visualisations

<p align="center">
<img src="q12_dataviz/review_mix_segments.png" width="900">
</p>

*Figure 12.1 — Review score distribution by customer segment, showing a clear increase in “excellent” ratings as customer loyalty rises.*

---

## Analytical Tables

**Table 12.1 — Review Score Distribution by Customer Segment**

Heavy-repeat customers are significantly more likely to leave highly positive feedback.

| Segment | Excellent | Good | Neutral | Bad | Very Bad |
|---|---|---|---|---|---|
| Heavy-repeat | 71.8% | 14.3% | 7.1% | 1.8% | 5.0% |
| Light-repeat | 62.9% | — | — | — | — |
| One-time | 58.9% | — | — | — | — |

*(Only selected rows shown for brevity in the summary table.)*

---

**Table 12.2 — Seller Response Time by Review Score**

Seller response behavior appears broadly consistent across sentiment categories.

| Review Score | Mean Response Days | Median Response Days |
|---|---|---|
| Excellent | 2.63 | 1 |
| Good | 2.54 | 1 |
| Neutral | 2.40 | 1 |
| Bad | 2.47 | 1 |
| Very Bad | 2.59 | 1 |

Median response time remains **1 day regardless of review sentiment**, indicating that sellers do not systematically delay or prioritize responses based on review score.

---

## Key Findings

* **Positive Loyalty Gradient:** Customer satisfaction increases with loyalty. While **58.9% of one-time buyers leave “excellent” reviews**, this share rises to **71.8% among heavy-repeat customers**.    

* **Low Severe Dissatisfaction:** Negative feedback remains relatively rare across all segments. Combined **bad and very bad reviews represent ~7% of heavy-repeat feedback**, compared to roughly **13% among one-time buyers**.  

* **Seller Communication Consistency:** Sellers typically respond to reviews within **one day**, regardless of sentiment. This suggests that response timing does not play a major role in shaping customer satisfaction outcomes.  

* **Acquisition Drives Complaint Volume:** Although one-time buyers have a higher share of negative reviews, they also represent **the vast majority of customers (~97%)**, meaning they contribute most of the platform’s total complaints in absolute terms.  

---

## Insight

➜ Customer satisfaction and loyalty appear to be **strongly correlated on the Olist platform**.

➜ Customers who leave highly positive reviews are significantly more likely to become repeat buyers. This indicates that **the first purchasing experience plays a critical role in determining long-term customer behaviour**.

➜ Improving the experience of first-time buyers—through reliable delivery, product quality, and accurate listings—may therefore be one of the most effective strategies for increasing retention.

➜ Because heavy-repeat customers exhibit the highest satisfaction levels, they also represent strong candidates for **referral programs, loyalty initiatives, and customer advocacy campaigns**.

➜ Heavy-repeat customers leave ~13 percentage points more “excellent” reviews than one-time buyers.

---

## Next Question

➡️ Next: Having confirmed that satisfaction correlates with loyalty, the next step is to quantify the financial impact of these segments: "How much revenue and profit do one‑time, light‑repeat, and heavy‑repeat customers generate, and does higher satisfaction (review score) translate into higher customer lifetime value?"
[q13_customer_revenue_profit_segments](../q13_revenue_by_repeat_segment/q13_README.md)

