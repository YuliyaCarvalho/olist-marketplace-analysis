# Executive Summary: Olist Marketplace Optimization & Logistics Risk Mitigation

> High-level findings from the full SQL + R analysis available in the **[`/business-questions`](./business_questions/)** directory. 

This project provides a **data-driven strategic roadmap** to enhance Olist's operational efficiency and customer retention.  

By analyzing marketplace records from **2016–2018**, the study finds that while the platform is operationally healthy and seller-diversified, **systemic logistics bottlenecks and low customer retention** represent the primary barriers to long-term profitability.

---

# Core Insights

## Delivery Speed is the Master Variable

Regression analysis confirms that **Delivery delay is the strongest observed predictor of dissatisfaction**.

- Crossing the **3-day delay threshold** causes negative reviews to spike **265%**  
  *(from 20% to 73%)*.

**Hypothesis rejected:**  
Contrary to intuition, **low freight costs do not make customers more tolerant of delays**.  
Price and payment flexibility show **almost no impact on satisfaction**.

---

## The "2% Problem" (Seller Risk)

Marketplace risk is **highly concentrated** rather than widespread.

- Only **2% of sellers (37 individuals)** generate **22% of the platform’s revenue at risk** due to chronic lateness.

This indicates that **targeted intervention can significantly reduce operational risk** without broad platform disruption.

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

- **Repeat buyers show significantly higher lifetime value**, representing a major **untapped growth lever**.

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

- **~30% of total platform transaction volume**

This can be achieved with **minimal capital investment**.

### Estimated Result

- A **2% increase in repeat purchase rate** could generate approximately **300K BRL in additional annual GMV**.
