**Operations & Logistics → q15 Operational Drivers of Satisfaction & Revenue**

# Business Question 15 — Operational Drivers of Customer Satisfaction

## Question

**Which operational factors (delivery delays, freight cost, payment type and seller performance) have the strongest impact on review scores and revenue, and where are the biggest opportunities to improve margin without hurting satisfaction?**

---

## Why This Matters

This analysis identifies the **true operational levers of customer satisfaction** on the Olist platform.

By isolating which operational factors actually influence review scores, Olist can prioritize logistics investments where they matter most while identifying areas where margins can be safely improved. For example, if customers are insensitive to freight costs but highly sensitive to delivery delays, the platform could increase freight margins on reliable routes without harming customer satisfaction.

Additionally, this analysis enables the development of a **targeted seller risk framework**, allowing Olist to intervene with the small subset of sellers responsible for a disproportionate share of negative experiences.

---

## Analytical Approach

To quantify the operational drivers of customer satisfaction, the analysis combined hypothesis testing, seller risk scoring, and regression modeling.

---

### Hypothesis Testing

The first stage tested whether **high freight costs reduce customer tolerance for delivery delays**.

Orders were segmented by:

- delay duration
- freight cost as a percentage of order value

This allowed comparison of review outcomes across different cost–delay combinations.

---

### Seller Risk Framework

A **volume-weighted composite risk score** was constructed to identify sellers creating disproportionate operational risk.

The score incorporates four components:

| Risk Component | Weight |
|---|---|
| Lateness frequency | 25% |
| Delay severity | 35% |
| Customer satisfaction | 25% |
| Complaint rate | 15% |

Based on this score, sellers were classified into five operational tiers:

- Critical  
- High  
- Medium  
- Low  
- Minimal  

---

### Predictive Modeling

Two regression models were built to isolate the independent effect of each operational variable.

**Model 1 — Order-Level**

Evaluates how specific order conditions affect review scores:

- delivery delay
- freight cost ratio
- payment installments

---

**Model 2A — Seller-Level**

Evaluates whether a seller's **historical reputation and consistency** influence customer satisfaction.

---

## Visualisations

<p align="center">
<img src="q15_dataviz/avg_review_delay.png" width="600">
</p>

*Figure 15.1 — Average Review Score by Delivery Delay, showing the rapid deterioration of satisfaction once an order passes its ETA.*

<p align="center">
<img src="q15_dataviz/low_review_share_delay.png" width="600">
</p>

*Figure 15.2 — Share of Low Reviews (1–2) by Delivery Delay, illustrating that over 70% of customers leave a negative review when an order is more than 3 days late.*

<p align="center">
<img src="q15_dataviz/delay_freight_interaction.png" width="800">
</p>

*Figure 15.3 — Interaction between delivery delays and freight cost, showing that customer dissatisfaction increases sharply with delay regardless of shipping price.*

<p align="center">
<img src="q15_dataviz/regression_coefficients.png" width="800">
</p>

*Figure 15.4 — Regression coefficients illustrating that delivery delay has a significantly stronger impact on review scores than freight cost or seller-level factors.*


---

## Analytical Tables

### Table 15.1 — Seller Risk Distribution

This table reveals that operational risk is highly concentrated among a small subset of sellers.

| Risk Tier | Sellers | Total Orders | Avg Risk Score | Revenue at Risk (BRL) |
|---|---|---|---|---|
| Critical | 5 | 158 | 97.3 | 46,700 |
| High | 32 | 333 | 84.9 | 35,076 |
| Medium | 141 | 7,052 | 49.4 | 757,959 |
| Low | 617 | 57,724 | 27.9 | 2,029,383 |
| Minimal | 1,069 | 42,713 | 9.7 | 779,114 |

Although most sellers operate reliably, a **very small group generates a disproportionate share of operational risk**.

---

### Table 15.2 — Order-Level Regression Model

| Variable | Coefficient (β) | Significance |
|---|---|---|
| Intercept | 3.86 | *** |
| Delay (days late) | -0.031 | *** |
| Installments (+1) | -0.034 | *** |
| Freight cost % | -0.002 | *** |

This confirms that **delivery delay is the strongest driver of dissatisfaction**.

---

## Key Findings

* **Delivery Delay is the Dominant Driver:** Delivery delay has the largest statistical impact on review scores.  
Each additional day of delay reduces the expected rating by approximately **0.03 points**.


* **Freight Cost Has Minimal Impact:** The hypothesis that lower freight costs soften the impact of delays was rejected.  
The proportion of negative reviews remains roughly **73% for late deliveries** regardless of whether shipping costs are low or high.

* **Individual Experience Outweighs Seller Reputation:** The order-level regression explains **3.5× more variance** than the seller-level model.
This indicates that customers react primarily to their **specific order experience**, rather than to a seller’s historical track record.

* **Operational Risk is Highly Concentrated:** Approximately **90% of sellers operate reliably**.  
However, just **37 sellers (~2% of the base)** account for **22% of total satisfaction risk**, making targeted interventions highly effective.

---

## Insight

➜ The most important operational improvement opportunity for Olist lies in **reducing delivery delays rather than reducing freight prices**.

➜ Because customers show relatively low sensitivity to shipping cost when deliveries are on time, Olist could increase freight margins on reliable routes and use the additional revenue to strengthen logistics infrastructure where delays occur more frequently.

➜ Furthermore, the analysis suggests that **real-time operational performance matters more than historical seller reputation**. Customers judge the platform primarily based on the outcome of their current order.

---

## Next Question

➡️ **Next:** Having identified the operational drivers of satisfaction under normal conditions, the next step is to examine whether **delivery delays become more damaging during peak seasonal demand periods**.  
[q16 Holiday Delay Impact](../q16_holiday_delay_impact/q16_README.md)
