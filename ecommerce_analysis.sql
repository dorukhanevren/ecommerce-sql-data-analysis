-- ========================================================
-- Project: E-Commerce Data Analysis & Business Intelligence
-- Author: Dorukhan Evren
-- Database Engine: MySQL / PostgreSQL Compatible
-- ========================================================

-- --------------------------------------------------------
-- 1. Database & Table Schema Setup
-- --------------------------------------------------------
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE,
    city VARCHAR(50)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10, 2)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    order_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- --------------------------------------------------------
-- 2. Customer Segmentation (RFM: Recency & Monetary)
-- --------------------------------------------------------
SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS total_orders,
    ROUND(COALESCE(SUM(o.total_amount), 0), 2) AS total_spent,
    MAX(o.order_date) AS last_purchase_date,
    CASE 
        WHEN SUM(o.total_amount) >= 5000 AND COUNT(o.order_id) >= 5 THEN 'VIP'
        WHEN SUM(o.total_amount) >= 2000 THEN 'Loyal Customer'
        WHEN COUNT(o.order_id) = 1 THEN 'New Customer'
        ELSE 'Regular'
    END AS customer_tier
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spent DESC;

-- --------------------------------------------------------
-- 3. Top-3 Revenue Generating Products per Category
--    (Window Function: DENSE_RANK)
-- --------------------------------------------------------
WITH ProductRevenueByCategory AS (
    SELECT 
        p.category,
        p.product_name,
        ROUND(SUM(oi.quantity * oi.price), 2) AS revenue,
        DENSE_RANK() OVER (
            PARTITION BY p.category 
            ORDER BY SUM(oi.quantity * oi.price) DESC
        ) AS rank_in_category
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Completed'
    GROUP BY p.category, p.product_name
)
SELECT 
    category,
    product_name,
    revenue,
    rank_in_category
FROM ProductRevenueByCategory
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;

-- --------------------------------------------------------
-- 4. MoM (Month-over-Month) Revenue Growth Trend
--    (Window Function: LAG)
-- --------------------------------------------------------
WITH MonthlyMetrics AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        ROUND(SUM(total_amount), 2) AS current_month_revenue
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT 
    sales_month,
    current_month_revenue,
    LAG(current_month_revenue, 1) OVER (ORDER BY sales_month) AS previous_month_revenue,
    ROUND(
        ((current_month_revenue - LAG(current_month_revenue, 1) OVER (ORDER BY sales_month)) / 
        NULLIF(LAG(current_month_revenue, 1) OVER (ORDER BY sales_month), 0)) * 100, 
        2
    ) AS mom_growth_rate_pct
FROM MonthlyMetrics
ORDER BY sales_month;

-- --------------------------------------------------------
-- 5. Performance Optimization & Execution Planning
-- --------------------------------------------------------
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_order_items_pid ON order_items(product_id);

EXPLAIN ANALYZE
SELECT 
    customer_id, 
    SUM(total_amount) AS total_spent
FROM orders
WHERE order_date >= '2025-01-01'
GROUP BY customer_id;
