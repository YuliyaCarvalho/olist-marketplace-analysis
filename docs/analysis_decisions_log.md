# Analysis Decisions Log

This document records key methodological decisions made during the analysis.

These decisions define how metrics were calculated and how data quality issues were handled in order to produce consistent analytical results.

---

# Data Granularity

**Decision:** Customer satisfaction and delivery performance analyses are conducted at **order level**, where each observation represents a single customer experience.

**Reason:** Reviews are recorded at order level. Using item-level data would duplicate observations for multi-item orders and violate independence assumptions, leading to biased results.

---

# GMV Definition

**Decision:** GMV is primarily calculated from payment values at order level.  
In analyses requiring seller or product attribution, GMV is derived from item-level revenue (`price + freight_value`) or proportionally allocated from order-level GMV.

**Reason:** Payment data reflects actual transaction value, while item-level data is required to preserve valid attribution across sellers and categories.

---

# Revenue at Risk Definition

**Decision:** Revenue at risk is defined as the value of orders that are both:
- delivered late
- associated with low customer satisfaction (≤ 2-star reviews)

**Reason:** This isolates revenue directly exposed to poor customer experience rather than total delayed revenue.

---

# Delivery Delay Definition

**Decision:** Delay is measured as the difference between actual delivery date and estimated delivery date (`delay_vs_eta`).

**Reason:** This reflects whether the platform met its promised delivery expectation, which is the basis for customer satisfaction.

---

# Micro-Payment Filtering

**Decision:** Payments below **1 BRL** and zero-value payments were excluded from monetary metrics such as:
> - GMV  
> - Average Order Value (AOV)  
> - Revenue per Customer  

**Reason:** These records typically represent:
> - voucher adjustments  
> - promotional credits  
> - technical placeholders  

Including them would artificially distort monetary metrics.

---

# Operational Integrity Filtering

**Decision:** Orders were excluded when:
- `timeline_is_valid = 0`
- `is_hanging = 1`

**Reason:** These records represent operational anomalies such as incomplete or logically inconsistent order timelines. 
Including them would bias delivery performance metrics.

---

# Time Aggregation Choice

**Decision:** Monthly aggregation uses:

`order_purchase_timestamp`

**Reason:** Purchase timestamps best represent **customer demand patterns**. Using fulfillment timestamps would distort the interpretation of
marketplace growth.

---

# Statistical Reliability Threshold

**Decision:** Deep-dive analyses of specific routes or cities were performed only when the sample size met a minimum threshold:

**`n ≥ 50 orders`**

**Reason:** Small sample sizes produce high variance and unstable estimates. The threshold reduces noise and prevents overinterpreting outliers.
