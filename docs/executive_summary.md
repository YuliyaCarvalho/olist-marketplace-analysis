# Executive Summary: Olist Marketplace Optimization & Logistics Risk Mitigation

> High-level findings from the full SQL + R analysis available in the **[`/business-questions`](./business_questions/)** directory. 

This project provides a **data-driven strategic roadmap** to enhance Olist's operational efficiency and customer retention.  

By analyzing marketplace records from **2016–2018**, the study finds that while the platform is operationally healthy and seller-diversified, **systemic logistics bottlenecks and low customer retention** represent the primary barriers to long-term profitability.

---

# Core Insights

## Delivery Delay is the Primary Operational Driver

Regression analysis confirms that **Delivery delay is the strongest observed predictor of dissatisfaction**.

- Low-review share increases sharply from ~20% to ~70% once delays exceed 3 days.  
  

**Hypothesis rejected:**  
Contrary to intuition, **low freight costs do not make customers more tolerant of delays**.  
Price and payment flexibility show **almost no impact on satisfaction**.

---

## The "2% Problem" (Seller Risk)

Marketplace risk is concentrated rather than evenly distributed.

A small group of high-risk sellers accounts for a disproportionate share of delay-related revenue at risk. This risk is driven by consistently poor processing and late-delivery patterns rather than isolated failures.

This indicates that **targeted seller intervention can reduce operational risk without requiring broad platform-wide enforcement**.

---

## Route-Specific Infrastructure Gaps

Logistics performance is primarily driven by **geography**, not only seller inefficiency.

- **14 specific routes (11% of total routes)** represent **28% of all platform orders**.
- The **São Paulo → Rio de Janeiro (SP → RJ)** corridor emerges as the **highest-impact failure point**.

Improving performance along these corridors would produce **outsized operational gains**.

---

## Retention Vulnerability

Olist currently behaves like a **“one-shot marketplace.”**

- **94% of GMV** comes from **one-time buyers**.

However:

- **Repeat buyers generate ~92% higher revenue per customer (273 BRL vs 146 BRL)**, representing a major **untapped growth lever**.

---

# Strategic Action Plan

## 1. Immediate Operational Fixes

**Target the SP → RJ route**

- Partner with **local RJ carriers**
- Improve last-mile delivery in cities such as **São Gonçalo** and **Cabo Frio**

This corridor alone accounts for **56% of all “Critical” volume**.

**Aggressive seller intervention**

- Conduct immediate reviews for the **5 critical-tier sellers**
- These sellers currently expose **~47K BRL of revenue to risk**

**Recalibrate ETAs**

- Align delivery promises with **actual infrastructure performance**
- Many states currently deliver **7–19 days earlier than promised**, creating artificially padded expectations that obscure real bottlenecks.

---

## 2. Short-to-Medium Term Infrastructure Improvements

**Decentralize fulfillment**

- Establish a **Bahia (BA) fulfillment center**
- Expected to reduce **Northeast delivery times by 40–50%**
- Reduces the platform’s **70% dependency on São Paulo logistics hubs**

**Tiered seller support system**

Replace binary *good/bad* seller flags with a **Composite Risk Score** that accounts for:

- lateness frequency
- lateness severity

This enables targeted training for the **141 medium-risk sellers**.

---

## 3. Growth & Retention Strategy

**Targeted retention campaigns**

Focus on **one-time credit card buyers** in high-volume states:

- São Paulo (SP)
- Rio de Janeiro (RJ)
- Minas Gerais (MG)
- Paraná (PR)

Goal: convert them into **repeat customers**.

**Category cross-selling**

Promote high-repeat categories through personalized recommendations:

- `bed_bath_table`
- `sports_leisure`

Objective:

- increase repeat customer share **from 3% to 5%**

---

# Financial Impact Summary

### Total Addressable Opportunity

By improving the **14 critical routes**, intervening with **high-risk sellers**, and strengthening **customer retention**, Olist could positively impact:

- **~30% of total platform transaction volume** (based on concentration across high-volume routes and seller segments identified in the analysis)

This can be achieved with **minimal capital investment**.

### Estimated Result

- A **2% increase in repeat purchase rate** could generate approximately **300K BRL in additional annual GMV**.

These estimates are directional and based on observational analysis. Actual impact would depend on implementation effectiveness and external operational constraints.