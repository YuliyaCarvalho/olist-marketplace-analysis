# Analysis Decisions Log

This document records key methodological decisions made during the analysis.

These decisions define how metrics were calculated and how data quality issues were handled in order to produce consistent analytical results.

---

# GMV Definition

**Decision:** Gross Merchandise Value (GMV) is calculated as the sum of payment values for **delivered orders only**.
**Reason:** Cancelled, unavailable, or incomplete orders do not represent completed marketplace transactions and therefore should not contribute to revenue metrics.

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

`**n ≥ 50 orders**`

**Reason:** Small sample sizes can produce unstable or misleading conclusions. This threshold ensures that reported insights are statistically meaningful.
