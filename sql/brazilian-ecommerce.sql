CREATE DATABASE brazilian_ecommerce;
USE  brazilian_ecommerce;

CREATE TABLE order_items (
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,   
    price TEXT,
    freight_value TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

SELECT 
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status,
    oi.product_id,
    oi.price,
    oi.freight_value
FROM olist_orders_dataset oorder_items
JOIN order_items oi
ON o.order_id = oi.order_id
LIMIT 10;

SELECT 
    SUM(CAST(price AS FLOAT)) AS total_revenue
FROM order_items;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(CAST(oi.price AS FLOAT)) AS monthly_revenue
FROM olist_orders_dataset o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

SET SQL_SAFE_UPDATES = 0;
UPDATE olist_orders_dataset
SET order_purchase_timestamp = STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y %H:%i');

SET SQL_SAFE_UPDATES = 1;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(CAST(oi.price AS FLOAT)) AS monthly_revenue
FROM olist_orders_dataset o
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
ORDER BY month;

SELECT 
    product_id,
    SUM(CAST(price AS FLOAT)) AS total_revenue
FROM order_items
GROUP BY product_id
ORDER BY total_revenue DESC
LIMIT 10;

SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

SET SQL_SAFE_UPDATES = 0;

UPDATE olist_orders_dataset
SET order_delivered_customer_date = STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y %H:%i')
WHERE order_delivered_customer_date != '';

SET SQL_SAFE_UPDATES = 1;
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

SELECT 
    customer_id,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

CREATE TABLE customers (
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT 
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

SELECT 
    c.customer_state,
    SUM(CAST(oi.price AS FLOAT)) AS total_revenue
FROM customers c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT 
    c.customer_id,
    SUM(CAST(oi.price AS FLOAT)) AS total_spent
FROM customers c
JOIN olist_orders_dataset o
ON c.customer_id = o.customer_id
JOIN order_items oi
ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

CREATE TABLE products (
    product_id TEXT,
    product_category_name TEXT,
    product_name_length TEXT,
    product_description_length TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT
);

LOAD DATA INFILE  'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE payments (
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/olist_order_payments_dataset.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM payments;

CREATE TABLE sellers (
    seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.5/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) FROM sellers;

SELECT 
    payment_type,
    COUNT(*) AS total_payments,
    SUM(CAST(payment_value AS FLOAT)) AS total_amount
FROM payments
GROUP BY payment_type
ORDER BY total_amount DESC;

SELECT 
    p.product_category_name,
    SUM(CAST(oi.price AS FLOAT)) AS total_revenue
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

SELECT 
    s.seller_id,
    SUM(CAST(oi.price AS FLOAT)) AS total_revenue
FROM sellers s
JOIN order_items oi
ON s.seller_id = oi.seller_id
GROUP BY s.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(CAST(p.payment_value AS FLOAT)) AS revenue
FROM olist_orders_dataset o
JOIN payments p
ON o.order_id = p.order_id
GROUP BY month
ORDER BY month;

SELECT 
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p 
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

SELECT 
    c.customer_state,
    SUM(oi.price) AS revenue
FROM customers c
JOIN olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price) AS revenue
FROM olist_orders_dataset o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

SELECT 
    c.customer_state,
    SUM(oi.price) AS revenue
FROM customers c
JOIN olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_value
FROM payments
GROUP BY payment_type
ORDER BY total_value DESC;

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    SUM(oi.price) AS revenue
FROM olist_orders_dataset o
JOIN order_items oi 
    ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;