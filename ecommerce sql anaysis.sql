create database ecommerce;
use ecommerce;
DROP TABLE IF EXISTS customers_raw;
CREATE TABLE customers_raw (
    customer_id       INT,
    customer_name     VARCHAR(100),
    email             VARCHAR(150),
    city              VARCHAR(50),
    state             VARCHAR(50),
    signup_date       VARCHAR(20),
    customer_segment  VARCHAR(30)
);
 
DROP TABLE IF EXISTS products_raw;
CREATE TABLE products_raw (
    product_id    INT,
    product_name  VARCHAR(150),
    category      VARCHAR(50),
    brand         VARCHAR(50),
    unit_price    VARCHAR(30)
);
 
DROP TABLE IF EXISTS orders_raw;
CREATE TABLE orders_raw (
    order_id        INT,
    customer_id     VARCHAR(20),    -- contains 'abc'
    order_date      VARCHAR(20),    -- mixed / invalid formats
    order_status    VARCHAR(30),
    payment_method  VARCHAR(30)
);
 
DROP TABLE IF EXISTS order_items_raw;
CREATE TABLE order_items_raw (
    order_item_id  INT,
    order_id       VARCHAR(20),     -- contains 'abc'
    product_id     VARCHAR(20),     -- contains 'unknown'
    quantity       VARCHAR(20),     -- contains '1.5', 'zero', '999'
    unit_price     VARCHAR(30)      -- contains 'free', 'unknown'
);

 -- Level 1: Basics (SELECT, WHERE, GROUP BY, COUNT)
-- 1.How many customers, products, orders and order lines are there?
SELECT
    (SELECT COUNT(*) FROM customers_raw)   AS total_customers,
    (SELECT COUNT(*) FROM products_raw)    AS total_products,
    (SELECT COUNT(*) FROM orders_raw)      AS total_orders,
    (SELECT COUNT(*) FROM order_items_raw) AS total_order_lines;
    
-- 2.How many orders are there in each status?
 select order_status,count(order_status) from orders_raw
 group by order_status;

-- 3.What share of orders uses each payment method?
select payment_method,count(order_id) as orders 
from orders_raw group by payment_method;

-- 4.How many customers live in each state and city?
select count(customer_id),city,state 
from customers_raw group by city,state;

-- 5.How many products are there in each category and brand?
select count(product_name) as count_p,category,brand
from products_raw group by category,brand;


-- Level 2: Joins and aggregation
-- 6.What is the total revenue?
select round(sum(quantity*unit_price),2) 
as revenue from order_items_raw;

-- 7.What is the revenue by product category?
select p.category,round(sum(oi.quantity*oi.unit_price),2)as revenue
from order_items_raw as oi join products_raw as p 
on p.product_id=oi.product_id 
where quantity is not null 
group by p.category 
order by revenue desc;

-- 8.Which 10 products earn the most revenue?
select p.product_name,round(sum(oi.quantity*oi.unit_price),2) as revenue 
from order_items_raw as oi join products_raw as p 
on p.product_id=oi.product_id 
group by p.product_name
order by revenue desc
limit 10;

-- 9.What is the revenue by customer segment (Regular, Silver, Gold, Platinum, VIP)?
select c.customer_segment,round(sum(oi.quantity*oi.unit_price),2) as revenue 
from order_items_raw as oi join orders_raw as o
on oi.order_id=o.order_id 
join customers_raw as c on c.customer_id=o.customer_id 
group by customer_segment;

-- 10.Which 5 states earn the most revenue?
select c.state,round(sum(oi.quantity*oi.unit_price),2) as revenue 
from order_items_raw as oi join orders_raw as o
on oi.order_id=o.order_id 
join customers_raw as c on c.customer_id=o.customer_id 
group by c.state
order by revenue desc;

-- 11.What is the average order value?
select count(order_id),round(avg(quantity*unit_price),2) as avg_revenue 
from order_items_raw;

-- 12.Who are the top 10 customers by total spend?
select c.customer_name, round(sum(oi.quantity*oi.unit_price),2) as spend
from order_items_raw as oi join orders_raw as o 
on oi.order_id=o.order_id 
join customers_raw as c 
on o.customer_id=c.customer_id 
group by customer_name
order by spend desc
limit 10;

-- Level 3: Dates and business KPIs
-- 13.How does revenue compare between 2024 and 2025, and which months wise also?
select year(o.order_date),count(distinct o.order_id)as orders ,round(sum(oi.quantity*oi.unit_price),2) as revenue from orders_raw as o
join order_items_raw as oi on o.order_id=oi.order_id 
group by year(o.order_date)
order by revenue desc;

select month(o.order_date),monthname(o.order_date),
round(sum(case when year(o.order_date)=2024
then oi.quantity*oi.unit_price end),2) as rev_2024,
round(sum(case when year(o.order_date)=2025
then oi.quantity*oi.unit_price end),2) as rev_2025
from orders_raw as o join order_items_raw as oi 
on o.order_id=oi.order_id where oi.quantity is not null 
and oi.unit_price 
group by month(o.order_date),monthname(o.order_date);

-- 14.What is the month-over-month growth %? (use LAG)
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_date, '%Y-%m')         AS order_month,
        SUM(oi.quantity * oi.unit_price)           AS revenue
    FROM orders_raw AS o
    JOIN order_items_raw AS oi
      ON o.order_id = oi.order_id
    WHERE oi.quantity IS NOT NULL
      AND o.order_date IS NOT NULL
    GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT
    order_month,
    ROUND(revenue, 2)                                          AS revenue,
    ROUND(LAG(revenue) OVER (ORDER BY order_month), 2)         AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY order_month))
          / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0) * 100, 2) AS mom_growth_pct
FROM monthly
ORDER BY order_month;

-- 15. What are the cancellation and return rates, and how much revenue sits in cancelled and returned orders?
SELECT
    COUNT(*)                                                    AS total_orders,
    SUM(order_status = 'Cancelled')                             AS cancelled_orders,
    SUM(order_status = 'Returned')                              AS returned_orders,
    ROUND(SUM(order_status = 'Cancelled') * 100.0 / COUNT(*), 2) AS cancel_rate_pct,
    ROUND(SUM(order_status = 'Returned')  * 100.0 / COUNT(*), 2) AS return_rate_pct
FROM orders_raw
WHERE order_status <> 'Unknown';

SELECT
    o.order_status,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) * 100.0
          / SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 2) AS revenue_share_pct
FROM order_items_raw oi
JOIN orders_raw as o ON o.order_id = oi.order_id
WHERE oi.quantity IS NOT NULL
GROUP BY o.order_status
ORDER BY revenue DESC;

SELECT
    ROUND(SUM(CASE WHEN o.order_status IN ('Cancelled', 'Returned')
                   THEN oi.quantity * oi.unit_price END), 2) AS revenue_at_risk,
    ROUND(SUM(CASE WHEN o.order_status IN ('Cancelled', 'Returned')
                   THEN oi.quantity * oi.unit_price END) * 100.0
          / SUM(oi.quantity * oi.unit_price), 2)             AS pct_of_total_revenue
FROM order_items_raw oi
JOIN orders_raw o ON o.order_id = oi.order_id
WHERE oi.quantity IS NOT NULL;

-- 16.Which payment method has the highest cancellation rate?
SELECT
    payment_method,
    COUNT(*)                                                      AS total_orders,
    SUM(order_status = 'Cancelled')                               AS cancelled_orders,
    ROUND(SUM(order_status = 'Cancelled') * 100.0 / COUNT(*), 2)  AS cancel_rate_pct
FROM orders_raw
WHERE order_status <> 'Unknown'
GROUP BY payment_method
ORDER BY cancel_rate_pct DESC;

-- Level 4: Advanced (CTEs, window functions, subqueries)

-- 17.Which customers have never placed an order?
SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.customer_segment,
    c.signup_date
FROM customers_raw c
LEFT JOIN orders_raw o
       ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

SELECT COUNT(*) AS customers_with_no_orders
FROM customers_raw c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders_raw o
    WHERE o.customer_id = c.customer_id
);

-- 18.What percentage of customers ordered more than once?
SELECT
    COUNT(*)                                          AS customers_who_ordered,
    SUM(order_count > 1)                              AS repeat_customers
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders_raw
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) AS customer_orders;
SELECT order_count, COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM orders_raw
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) t
GROUP BY order_count
ORDER BY order_count;

-- 19. What are the top 3 products in each category? (use RANK or DENSE_RANK)
WITH product_revenue AS (
    SELECT
        p.category,
        p.product_id,
        p.product_name,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items_raw oi
    JOIN products_raw p ON p.product_id = oi.product_id
    WHERE oi.quantity IS NOT NULL
    GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
    SELECT
        category, product_name, revenue,
        DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_revenue
)
SELECT category, rnk, product_name, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;
