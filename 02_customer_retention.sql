/* 
02_customer_retention.sql
Author: Budhaditya Das

Uses same customers + orders tables as 01_sales_analysis_basic.sql
*/

-- 1. First order date per customer (cohort assignment)
WITH first_order AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
)
SELECT * FROM first_order;

-- 2. Monthly new vs returning customers
WITH first_order AS (
    SELECT 
        customer_id,
        MIN(order_date) AS first_order_date
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
),
orders_labeled AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        CASE 
            WHEN o.order_date = fo.first_order_date THEN 'New'
            ELSE 'Returning'
        END AS customer_type
    FROM orders o
    JOIN first_order fo 
        ON o.customer_id = fo.customer_id
    WHERE o.order_status = 'Completed'
)
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    customer_type,
    COUNT(DISTINCT customer_id) AS customers
FROM orders_labeled
GROUP BY DATE_TRUNC('month', order_date), customer_type
ORDER BY month, customer_type;

-- 3. Simple retention: customers who ordered in consecutive months
WITH month_orders AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_date) AS month
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
),
lagged AS (
    SELECT 
        customer_id,
        month,
        LAG(month) OVER (PARTITION BY customer_id ORDER BY month) AS prev_month
    FROM month_orders
)
SELECT 
    month,
    COUNT(DISTINCT customer_id) AS retained_customers
FROM lagged
WHERE prev_month IS NOT NULL
  AND month = prev_month + INTERVAL '1 month'
GROUP BY month
ORDER BY month;
