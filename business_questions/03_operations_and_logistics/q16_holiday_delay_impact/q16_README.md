**Operations & Logistics → q16 Holiday Delay Impact**

# Business Question 16 — Do Delays Hurt More During Holidays?

## Question

**Do delivery delays cause a larger drop in customer satisfaction during holiday and peak shopping periods compared to regular periods?**

---

## Why This Matters

Peak shopping periods place significant strain on logistics systems while simultaneously raising customer expectations.

Events such as **Christmas, Mother's Day, and other major shopping occasions** combine high order volumes with time-sensitive purchasing behavior. When deliveries are delayed during these periods, the reputational damage can be greater because customers often depend on precise delivery timing for gifts or promotional purchases.

Understanding whether customers penalize delays more harshly during holidays allows Olist to:

- adjust delivery expectations during high-risk periods  
- improve communication strategies  
- proactively protect customer satisfaction during seasonal peaks  

---

## Analytical Approach

To quantify the relationship between delays, holidays, and satisfaction, the analysis combined **temporal segmentation and regression modeling**.


### Holiday Segmentation

Shopping periods were classified into two broad categories:

**High-Expectation Holidays:** Events where delivery timing is emotionally important:

> - Christmas  
> - Mother’s Day  
> - Father’s Day  

**High-Volume Promotional Events:** Events driven primarily by discounts and increased purchasing volume:

> - Black November  
> - Carnival  

---

### Temporal Windows

Each event was analyzed using custom time windows designed to capture both **logistics pressure before the event** and **customer feedback afterwards**.

Example: `Christmas analysis window: -21 to +5 days`


This allows detection of both pre-holiday shipping strain and post-holiday review outcomes.

---

### Interaction Regression Model

A linear regression model was built to test whether the penalty for late deliveries increases during holiday periods.
`review_score_num ~ delay_vs_eta * is_holiday_period`

The interaction term tests whether **delay has a stronger effect on reviews during holidays than during normal periods**.

---

### Financial Impact Mapping

To assess the economic exposure of delays, the analysis calculated **revenue at risk for each shopping period**.

Revenue at risk represents the total value of orders delivered late within each period.

---

## Visualisations

<p align="center">
<img src="q16_dataviz/low_review_rate_heatmap.png" width="700">
</p>

*Figure 16.1 — Share of Low Reviews by Delivery Performance and Shopping Period: A heatmap showing that "Severely Late" (>3 days) orders during Christmas and Carnival trigger the highest rates of dissatisfaction (77.1%–77.9% low reviews)*

<p align="center">
<img src="q16_dataviz/on_time_vs_late_satisfaction.png" width="700">
</p>

*Figure 16.2 — Customer Satisfaction: On-time vs. Late Deliveries: Compares average review scores across periods. Relationship holidays like Father's Day show much higher tolerance for lateness (3.47 avg score) than promotional events like Carnival (2.21 avg score)*

<p align="center">
<img src="q16_dataviz/satisfaction_drop_ranked.png" width="700">
</p>

*Figure 16.3 — Satisfaction Drop When Late (Ranked by Impact): Ranks periods by the magnitude of the satisfaction decrease. Promotional events and Christmas show the largest "pain" from delays, with scores dropping by ~1.8 to 1.9 points*

<p align="center">
<img src="q16_dataviz/revenue_risk_vs_satisfaction.png" width="900">
</p>

*Figure 16.4 — Revenue Risk vs. Customer Satisfaction Impact: Relates the satisfaction drop to the percentage of revenue at risk. Christmas and Valentine's Day occupy the most vulnerable quadrants.*

<p align="center">
<img src="q16_dataviz/cumulative_revenue_risk_waterfall.png" width="800">
</p>

*Figure 16.5 — Cumulative Revenue at Risk from Late Deliveries: A waterfall chart illustrating that while holidays have acute per-order risks, the sheer volume of "Regular" periods accounts for R$933K (64.8%) of total platform revenue at risk.*

---

## Analytical Tables

### Table 16.1 — Satisfaction Impact of Late Deliveries

| Shopping Period | Avg Score (Late) | Avg Score (On Time) | Satisfaction Drop | % Drop |
|---|---|---|---|---|
| Carnival | 2.21 | 4.12 | 1.91 | 46.4% |
| Christmas | 2.37 | 4.18 | 1.81 | 43.3% |
| Black November | 2.39 | 4.14 | 1.75 | 42.3% |
| Regular | 2.50 | 4.23 | 1.73 | 40.9% |
| Mother's Day | 3.10 | 4.25 | 1.15 | 27.1% |
| Father's Day | 3.47 | 4.33 | 0.86 | 19.9% |

---

### Table 16.2 — Revenue at Risk by Shopping Period

| Shopping Period | Total Revenue (BRL) | Revenue at Risk (BRL) | % Revenue at Risk |
|---|---|---|---|
| Valentine's Day | 55,187 | 39,361 | 71.3% |
| Carnival | 66,353 | 41,236 | 62.1% |
| Christmas | 108,219 | 66,086 | 61.1% |
| Regular | 1,535,741 | 933,465 | 60.8% |
| Father's Day | 161,911 | 57,181 | 35.3% |

---

## Key Findings

* **Purchase Motivation Influences Tolerance:** Customer tolerance for delays varies depending on the reason for the purchase.  
Delays have the **largest impact during promotional events** like Carnival and Black November.


* **Promotional Events Show the Largest Satisfaction Drop:** Price-driven shopping events experience the most severe satisfaction penalties when orders arrive late.
Carnival shows the largest decline in reviews (**46% satisfaction drop**).


* **Family Holidays Show Greater Customer Forgiveness:** Customers appear more tolerant during sentimental occasions such as **Mother’s Day and Father’s Day**, where the drop in satisfaction is significantly smaller.


* **Christmas Represents the Highest Operational Risk:** Christmas combines high logistics demand with strict delivery expectations, producing one of the largest satisfaction penalties when delays occur.


* **No Strong Global Holiday Interaction Effect:** The regression interaction term between **delay and holiday status was not statistically significant (p = 0.345)**.
This indicates that delays do not systematically hurt more during holidays in aggregate, even though **specific events exhibit stronger local effects**.

---

## Insight

➜ The impact of delivery delays during holidays depends more on **customer purchase motivation** than on the calendar itself.

➜ Promotional shopping events create customers who are highly price-sensitive and less tolerant of logistical friction. In contrast, emotionally motivated purchases tend to produce more forgiving customers.

➜ For Olist, this suggests a differentiated operational strategy:

> - prioritize logistics speed during **discount-driven events**
> - focus on **communication and expectation management** during sentimental holidays
> - extend delivery estimates before **Christmas** to buffer seasonal logistics strain

---

## Next Question

➡️ **Next:** After evaluating how seasonal demand influences delivery performance, the next step is to investigate **geographic logistics constraints across Brazil**.
[q17 Geographic Delivery Performance](../q17_geographic_delivery_performance/q17_README.md)