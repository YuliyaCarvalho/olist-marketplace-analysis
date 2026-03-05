# Data Dictionary

Dataset source: [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
---

# Data Dictionary

## Entity Relationship Diagram

![Dataset ERD](dataset_erd.png)

This document describes the structure of the datasets used in the **Olist Marketplace Analysis** project.

The data originates from the **Olist Brazilian E-Commerce Public Dataset (2016–2018)** and was loaded into **Google BigQuery**, where additional cleaned and derived tables were created for analysis.

The dataset contains transactional marketplace data including orders, payments, products, sellers, customers, reviews, and geographic information.


The schema is organized into three layers:

- **Raw source tables** (original dataset structure)
- **Processed / analytical tables (`*_final`)**
- **Reference and lookup tables**

---

# Data Dictionary

This document describes the structure of the datasets used in the **Olist Marketplace Analysis** project.

The data originates from the **Olist Brazilian E-Commerce Public Dataset (2016–2018)** and was loaded into **Google BigQuery**, where additional cleaned and derived tables were created for analysis.

The schema is organized into three layers:

- **Raw source tables** (original dataset structure)
- **Processed / analytical tables (`*_final`)**
- **Reference and lookup tables**

---

# 1. Raw Source Tables

## orders

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Unique identifier for the order across all tables |
| customer_id | STRING | Unique identifier of the customer who placed the order |
| order_status | STRING | Current lifecycle state of the order (created, shipped, delivered, etc.) |
| order_purchase_timestamp | TIMESTAMP | Timestamp when the customer completed checkout |
| order_approved_at | TIMESTAMP | Timestamp when payment was approved and the order became eligible for fulfillment |
| order_delivered_carrier_date | TIMESTAMP | Timestamp when the seller handed the package to the logistics carrier |
| order_delivered_customer_date | TIMESTAMP | Timestamp when the customer received the package (carrier confirmed) |
| order_estimated_delivery_date | TIMESTAMP | Estimated delivery date promised to the customer |

---

## order_items

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Unique identifier of the order |
| order_item_id | INTEGER | Line-item number within the order |
| product_id | STRING | Unique identifier of the purchased product |
| seller_id | STRING | Seller responsible for fulfilling the item |
| shipping_limit_date | TIMESTAMP | Deadline by which the seller must ship the item |
| price | FLOAT | Item price charged to the customer (excluding freight) |
| freight_value | FLOAT | Shipping cost allocated to the order item |

---

## payments

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Unique identifier of the order |
| payment_sequential | INTEGER | Sequence number of the payment entry within the order |
| payment_type | STRING | Payment method (credit_card, boleto, voucher, etc.) |
| payment_installments | INTEGER | Number of installments selected by the customer |
| payment_value | FLOAT | Monetary value of the payment transaction |

---

## reviews

| Column | Type | Description |
|------|------|------|
| review_id | STRING | Unique identifier of the review |
| order_id | STRING | Order associated with the review |
| review_score | STRING | Customer rating label (normalized from numeric score) |
| review_comment_title | STRING | Optional short title of the review |
| review_comment_message | STRING | Full review text written by the customer |
| review_creation_date | DATE | Date the review was created |
| review_answer_timestamp | TIMESTAMP | Timestamp when the seller responded to the review |

---

## products

| Column | Type | Description |
|------|------|------|
| product_id | STRING | Unique product identifier |
| product_category_name | STRING | Root product category name (Portuguese) |
| product_name_length | INTEGER | Number of characters in the product name |
| product_description_length | INTEGER | Number of characters in the product description |
| product_photos_qty | INTEGER | Number of product images available |
| product_weight_g | INTEGER | Product weight in grams |
| product_length_cm | INTEGER | Product length in centimeters |
| product_height_cm | INTEGER | Product height in centimeters |
| product_width_cm | INTEGER | Product width in centimeters |

---

## sellers

| Column | Type | Description |
|------|------|------|
| seller_id | STRING | Unique identifier assigned to each marketplace seller |
| seller_zip_code_prefix | INTEGER | First digits of the seller’s ZIP code |
| seller_city | STRING | City where the seller operates |
| seller_state | STRING | Two-letter state abbreviation |

---

## customers

| Column | Type | Description |
|------|------|------|
| customer_id | STRING | Unique identifier for a customer order record |
| customer_unique_id | STRING | Stable identifier representing the actual customer |
| customer_zip_code_prefix | INTEGER | First digits of the customer’s postal code |
| customer_city | STRING | City where the customer receives deliveries |
| customer_state | STRING | Two-letter Brazilian state code |

---

## geolocation

| Column | Type | Description |
|------|------|------|
| geolocation_zip_code_prefix | INTEGER | Prefix of the Brazilian postal code |
| geolocation_lat | FLOAT | Latitude coordinate (WGS-84) |
| geolocation_lng | FLOAT | Longitude coordinate (WGS-84) |
| geolocation_city | STRING | City associated with the location |
| geolocation_state | STRING | State abbreviation |

---

# 2. Reference Tables

## product_category_name_translation

| Column | Type | Description |
|------|------|------|
| product_category_name | STRING | Product category name in Portuguese |
| product_category_name_english | STRING | English translation of the category |

---

# 3. Processed Analytical Tables

These tables were created in **BigQuery** to improve data quality, enforce timeline consistency, and support analytical workflows.

---

## orders_final

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Unique identifier of the order |
| customer_id | STRING | Identifier of the customer placing the order |
| order_status | STRING | Final lifecycle status of the order |
| order_purchase_timestamp | TIMESTAMP | Datetime when the order was placed |
| order_approved_at | TIMESTAMP | Datetime when the payment was approved |
| order_delivered_carrier_date | TIMESTAMP | Datetime when the package was handed to the carrier |
| order_delivered_customer_date | TIMESTAMP | Datetime when the order reached the customer |
| order_estimated_delivery_date | TIMESTAMP | Promised delivery deadline |
| approval_lag_hours | FLOAT | Hours between purchase and payment approval |
| order_to_delivery_days | INTEGER | Days from purchase to customer delivery |
| timeline_is_valid | INTEGER | Flag indicating chronological consistency (purchase ≤ approval ≤ carrier ≤ delivery) |
| has_approval | INTEGER | Flag indicating whether approval timestamp exists |
| delivery_timestamp_is_complete | INTEGER | Flag indicating delivery timestamp availability |
| carrier_before_approval | INTEGER | QA flag for incorrect event ordering |
| carrier_before_purchase | INTEGER | QA flag for incorrect event ordering |
| customer_before_carrier | INTEGER | QA flag for incorrect event ordering |
| is_hanging | INTEGER | Flag identifying operationally incomplete or stalled orders |

---

## order_items_final

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Order identifier |
| order_item_id | INTEGER | Line-item index within the order |
| product_id | STRING | Product identifier |
| seller_id | STRING | Seller fulfilling the item |
| price | FLOAT | Item price (excluding freight) |
| freight_value | FLOAT | Shipping cost allocated to the item |
| product_category | STRING | Product category (English) |
| shipping_limit_date | TIMESTAMP | Seller’s shipment deadline |
| shipping_limit_days | INTEGER | Days between purchase and shipping deadline |
| shipping_limit_p99 | INTEGER | 99th percentile shipping deadline benchmark for category |
| shipping_limit_flag_p99 | INTEGER | Flag if shipping deadline exceeds P99 threshold |

---

## delivered_orders_items_final

An **item-level fact table** restricted to **completed deliveries**, combining lifecycle timestamps, delivery metrics, review data, and seller/product attributes.

This table ensures:

- clean separation between completed historical behavior and operational anomalies  
- validated event chronology  
- no artificial data imputation  

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Order identifier |
| order_item_id | INTEGER | Item index within the order |
| product_id | STRING | Product identifier |
| seller_id | STRING | Seller fulfilling the item |
| customer_id | STRING | Customer identifier |
| product_category | STRING | Product category (English label) |
| price | FLOAT | Item price |
| freight_value | FLOAT | Shipping cost |
| order_purchase_timestamp | TIMESTAMP | Order purchase timestamp |
| order_approved_at | TIMESTAMP | Payment approval timestamp |
| order_delivered_carrier_date | TIMESTAMP | Carrier handoff timestamp |
| order_delivered_customer_date | TIMESTAMP | Customer delivery timestamp |
| approval_lag_hours | FLOAT | Hours between purchase and approval |
| order_to_delivery_days | INTEGER | Total delivery duration |
| carrier_to_customer_days | INTEGER | Days from carrier pickup to delivery |
| review_score | STRING | Normalized customer review score |
| delivery_performance | INTEGER | Delivery speed category (fast → very slow) |
| timeline_is_valid | INTEGER | Chronological integrity flag |

---

## payments_final

| Column | Type | Description |
|------|------|------|
| order_id | STRING | Order identifier |
| payment_sequential | INTEGER | Payment sequence number |
| payment_type | STRING | Payment method |
| payment_installments | INTEGER | Number of installments |
| payment_value | FLOAT | Transaction value |
| is_micro_payment | INTEGER | Flag for payments between 0 and 1 BRL |
| is_zero_payment | INTEGER | Flag for zero-value payments |

---

# Summary

The analytical warehouse structure supports marketplace analysis across:

- **order lifecycle performance**
- **delivery logistics**
- **seller behavior**
- **customer satisfaction**
- **payment dynamics**