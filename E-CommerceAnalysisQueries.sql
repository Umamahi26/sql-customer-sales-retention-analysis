
-- REVENUE ANALYSIS

-- Total revenue generated
SELECT
	SUM(amount) AS total_revenue
FROM orders;

-- Monthly revenue trend
SELECT
    FORMAT(order_date,'yyyy-MM') AS year_month,
    SUM(amount) AS revenue
FROM orders
GROUP BY FORMAT(order_date,'yyyy-MM')
ORDER BY year_month;

-- City generating highest revenue
SELECT
	TOP 1
	c.city,
	SUM(o.amount) AS highest_revenue
FROM customers AS c
INNER JOIN orders AS o
ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY SUM(o.amount) DESC;

-- CUSTOMER PERFORMANCE

-- Top 3 customers by spending
SELECT
    TOP 3
	customer_id,
	SUM(amount) AS customer_spent
FROM orders
GROUP BY customer_id
ORDER BY customer_spent DESC;


--Customer revenue contribution %
SELECT
    order_id,
    amount,
    ROUND(amount * 100.0 / SUM(amount) OVER(),2) AS revenue_pct
FROM orders;

-- Latest order per customer
SELECT
    customer_id,
    order_id,
    order_date,
    amount
FROM (
    SELECT
        customer_id,
        order_id,
        order_date,
        amount,
        ROW_NUMBER() OVER(
            PARTITION BY customer_id
            ORDER BY order_date DESC
        ) AS rn
    FROM orders
) t
WHERE rn = 1
ORDER BY customer_id;

-- RETENTION BEHAVIOUR

-- Customers with purchase gap > 30 days
SELECT *
FROM
(SELECT
    customer_id,
    order_id,
    amount,
    DATEDIFF(
        DAY,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date),
        order_date
    ) AS days_gap
FROM orders) AS t
WHERE days_gap > 30;

-- Repeat vs one-time customers
SELECT
    customer_id,
    COUNT(order_id) AS total_orders,
    CASE
        WHEN COUNT(order_id) > 1 THEN 'Repeat Customer'
        ELSE 'One-time Customer'
    END AS customer_type
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;
