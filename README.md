# e-commerce-sql
E-commerce data analysis using MySQL. Explore sales performance, customer segmentation, product revenue, order trends, cancellation rates, and business KPIs using SQL queries, joins, CTEs, and window functions.

# 🛒 E-Commerce SQL Data Analysis Project

## 📌 Project Overview

This project focuses on analyzing an e-commerce business using **MySQL**. The objective is to extract meaningful business insights from customer, product, order, and order-item data using SQL queries.

The project covers basic SQL operations, data aggregation, joins, business KPIs, date-based analysis, Common Table Expressions (CTEs), subqueries, and window functions.

## 🎯 Project Objectives

- Analyze overall customer, product, and order data.
- Understand order status and payment method distribution.
- Calculate total revenue and revenue by product category.
- Identify top-performing products and customers.
- Analyze revenue by customer segment and geographical location.
- Compare yearly and monthly revenue trends.
- Calculate month-over-month revenue growth.
- Analyze cancellation and return rates.
- Identify repeat customers and customers who never placed orders.
- Rank top-performing products within each category.

## 🗂️ Database Structure

Database Name: `ecommerce`

The project uses four raw tables:

| Table Name | Description |
|---|---|
| customers_raw | Customer information, location, signup date, and segment |
| products_raw | Product details, categories, brands, and prices |
| orders_raw | Order dates, statuses, and payment methods |
| order_items_raw | Order items, product IDs, quantities, and prices |

## 🛠️ Tools & Technologies

- **Database:** MySQL
- **Language:** SQL
- **Concepts:** Data Analysis, Business Intelligence
- **Techniques:** Joins, Aggregations, CTEs, Subqueries, Window Functions

## 📊 Analysis & Business Questions

### Level 1: SQL Basics
- Total number of customers, products, orders, and order lines.
- Orders by status.
- Orders by payment method.
- Customer distribution by city and state.
- Product distribution by category and brand.

### Level 2: Joins & Revenue Analysis
- Calculate total revenue.
- Revenue by product category.
- Top 10 products by revenue.
- Revenue by customer segment.
- Top 5 states by revenue.
- Average order-item revenue.
- Top 10 customers by spending.

### Level 3: Business KPIs & Date Analysis
- Compare revenue between 2024 and 2025.
- Analyze monthly revenue trends.
- Calculate month-over-month revenue growth using LAG().
- Calculate cancellation and return rates.
- Analyze revenue associated with cancelled and returned orders.
- Identify payment methods with the highest cancellation rates.

### Level 4: Advanced SQL Analysis
- Identify customers who have never placed an order.
- Analyze repeat customer behavior.
- Rank the top 3 products in each category using DENSE_RANK().
- Use CTEs, subqueries, and window functions for advanced analysis.

## 🧠 SQL Concepts Practiced

- SELECT, WHERE, GROUP BY, ORDER BY
- COUNT(), SUM(), AVG(), ROUND()
- INNER JOIN and LEFT JOIN
- Common Table Expressions (CTEs)
- CASE WHEN statements
- Subqueries and correlated subqueries
- Window Functions
- LAG()
- DENSE_RANK()
- Date Functions
- NULL handling
- Business KPI calculations

## 📁 Project Files

```text
Ecommerce-SQL-Data-Analysis/
│
├── ecommerce_sql_analysis.sql
└── README.md
```

## 💡 Key Learning Outcomes

Through this project, I practiced applying SQL to real-world-style e-commerce business problems, including:

- Sales and revenue analysis.
- Customer segmentation and purchasing behavior.
- Product performance analysis.
- Business KPI calculations.
- Customer retention and repeat purchase analysis.
- Advanced SQL querying techniques.

## 👨‍💻 Author

**Vikas Yadav**

Aspiring Data Analyst | SQL | MySQL | Data Analysis

---

⭐ If you find this project useful, feel free to star the repository!
