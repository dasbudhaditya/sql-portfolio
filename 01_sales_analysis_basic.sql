/* 
01_sales_analysis_basic.sql
Author: Budhaditya Das

Assumed tables:

TABLE customers (
    customer_id      INT PRIMARY KEY,
    customer_name    VARCHAR(100),
    country          VARCHAR(50),
    signup_date      DATE
);

TABLE orders (
    order_id         INT PRIMARY KEY,
    customer_id      INT,
    order_date       DATE,
    order_status     VARCHAR(20),
    order_amount     DECIMAL(10,2)
);

TABLE products (
    product_id       INT PRIMARY KEY,
    product_name     VARCHAR(100),
    category         VARCHAR(50)
);

TABLE order_items (
    order_item_id    INT PRIMARY KEY,
    order_id         INT,
    product_id       INT,
    quantity         INT,
    line_amount      DECIMAL(10,2)
);
*/

-- 1. Total revenue by month
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(order_amount) AS total_revenue
FROM orders
WHERE order_status = 'Completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

-- 2. Top 5 customers by total revenue
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(o.order_amount) AS total_spent
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- 3. Number of orders and average order value by country
SELECT 
    c.country,
    COUNT(o.order_id) AS total_orders,
    AVG(o.order_amount) AS avg_order_value
FROM customers c
JOIN orders o 
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'Completed'
GROUP BY c.country
ORDER BY total_orders DESC;

-- 4. Revenue by product category
SELECT 
    p.category,
    SUM(oi.line_amount) AS category_revenue
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY category_revenue DESC;
