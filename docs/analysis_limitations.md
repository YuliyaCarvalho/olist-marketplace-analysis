# Analytical Limitations

This project is an educational case study based on historical
e-commerce marketplace data from **2016–2018**.

The purpose of the analysis is to demonstrate analytical reasoning
and data exploration techniques rather than to support current
business decision-making.

Because the dataset is **observational**, the analysis identifies
correlations but cannot establish causal relationships.

---

# Dataset Scope Limitations

## Limited Time Horizon

Customer retention and churn analysis are limited to the dataset
timeframe (2016–2018).

Long-term customer lifetime value (LTV) beyond this period cannot
be observed.

---

# Satisfaction Signal Limitations

Customer review scores contain significant unexplained variation.

Operational factors such as delivery delays explain only a small
portion of the variance in satisfaction.

Other important drivers are not captured in the structured dataset,
including:

- product quality
- seller communication
- pricing competitiveness
- buyer expectations

---

# Geographic Constraints

Delivery performance may be influenced by factors that are not
visible in the dataset, including:

- third-party carrier networks
- regional infrastructure differences
- urban logistics complexity

For example, dense metropolitan areas such as **Rio de Janeiro**
may exhibit unique delivery patterns due to local geography
and traffic conditions.

---

# ZIP Code Resolution

The dataset uses **5-digit ZIP code prefixes**.

A single prefix can correspond to multiple municipalities,
which introduces some ambiguity in geographic analysis.

As a result, route-level insights should be interpreted as
approximate geographic indicators rather than precise
municipal boundaries.

---

# Review Participation Bias

Leaving a review is optional for customers.

As a result, the review dataset may over-represent customers
with:

- extremely positive experiences
- extremely negative experiences

Customers with neutral experiences may be under-represented,
which can bias satisfaction analysis.