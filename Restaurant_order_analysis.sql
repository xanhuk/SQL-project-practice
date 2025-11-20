USE restaurant_db;

-- OBJECT 1: EXPLORE THE ITEMS TABLE
-- View the menu_items table.
SELECT * FROM menu_items;

-- Find number of items on the menu.
SELECT COUNT(*) FROM menu_items;

-- What are the least and most expensive items on the menu?
SELECT * FROM menu_items
ORDER BY price DESC;

-- How many Italian dish on the menu?
SELECT COUNT(*) FROM menu_items
WHERE category = 'Italian';

-- What are the least and most expensive Italian dishes on the menu?
SELECT * FROM menu_items
WHERE category = 'Italian'
ORDER BY price DESC;

-- How many dishes are in each category?
SELECT category, COUNT(*)
FROM menu_items
GROUP BY category;

-- What is the average dish price within each category
SELECT category, AVG(price)
FROM menu_items
GROUP BY category;

-- OBJECT 2: EXPLORE THE ORDERS TABLE
-- View the order_details table
SELECT * FROM order_details;

-- What is the date range of the table?
SELECT MIN(order_date), MAX(order_date)
FROM order_details;

-- How many orders were made within this date range ?
SELECT COUNT(distinct order_id)
FROM order_details;

-- How many items were ordered within this date range?
SELECT COUNT(*)
FROM order_details;

-- Which orders had the most number of items ?
SELECT order_id, COUNT(*)
FROM order_details
GROUP BY order_id 
ORDER BY COUNT(*) DESC;

-- How many orders had more than 12 items ?
SELECT COUNT(*) FROM
(SELECT order_id, COUNT(*)
FROM order_details
GROUP BY order_id 
HAVING COUNT(*) > 12) AS num;

-- OBJECT 3: ANALYSE CUSTOMER BEHAVIOR
-- Combine the menu_items and order_details into a single table 
SELECT *
FROM menu_items m
JOIN order_details o
ON m.menu_item_id = o.item_id;

-- What were the least and most ordered items ? What categories were they in?
SELECT m.item_name, m.category, COUNT(*)
FROM menu_items m
JOIN order_details o
ON m.menu_item_id = o.item_id
GROUP BY m.item_name, m.category
ORDER BY COUNT(*) DESC;

-- What were the top 5 orders that spent the most money?
SELECT o.order_id, SUM(m.price) AS total_spent
FROM menu_items m
JOIN order_details o
ON m.menu_item_id = o.item_id
GROUP BY o.order_id
ORDER BY total_spent DESC
LIMIT 5;

-- View the detail of the highest spend order. What insights can you gather from the result?
SELECT *
FROM menu_items m
JOIN order_details o
ON m.menu_item_id = o.item_id
WHERE order_id = 440
ORDER BY category;

-- View the details of the top 5 highest spend orders
SELECT *
FROM menu_items m
JOIN order_details o
ON m.menu_item_id = o.item_id
WHERE order_id IN  ('440', '2075', '1957','330', '2675')
ORDER BY category

