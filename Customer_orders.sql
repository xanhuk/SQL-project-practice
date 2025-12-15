USE customer_order;

SELECT * FROM customer_orders;

-- 1. Standardize the order_status column 
SELECT order_status,
CASE 
WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
WHEN LOWER(order_status) LIKE '%shipped%' THEN 'Shipped'
WHEN LOWER(order_status) LIKE '%returned%' THEN 'Returned'
WHEN LOWER(order_status) LIKE '%refunded%' THEN 'Refunded'
WHEN LOWER(order_status) LIKE '%pending%' THEN 'Pending'
ELSE 'Others'
END AS cleaned_order_status
FROM customer_orders;

-- 2. Standardize the product_name column 
SELECT product_name,
CASE 
WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
ELSE 'Others'
END AS cleaned_product_name
FROM customer_orders;

-- 3. Cleaning the quantity field 
SELECT quantity,
CASE 
WHEN quantity = 'two' THEN 2
ELSE CAST(quantity AS UNSIGNED)
END AS cleaned_quantity
FROM customer_orders;

-- 4. Cleaning the customer_name field
-- Create an UDF to capitalize the first letter of each words
DELIMITER //

CREATE FUNCTION initcap(str VARCHAR(255))
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE result VARCHAR(255);
    DECLARE i INT DEFAULT 1;

    SET result = LOWER(str);  -- Convert the entire string to lowercase

    WHILE i <= CHAR_LENGTH(result) DO
        IF i = 1 OR SUBSTRING(result, i - 1, 1) = ' ' THEN
            SET result = CONCAT(SUBSTRING(result, 1, i - 1), UPPER(SUBSTRING(result, i, 1)), SUBSTRING(result, i + 1));
        END IF;
        SET i = i + 1;
    END WHILE;

    RETURN result;
END//

DELIMITER ;

-- Use the function in the customer_name column 
SELECT customer_name,
initcap(customer_name) AS customer_name
FROM customer_orders
WHERE customer_name IS NOT NULL;

-- 5. Remove duplicates order 
SELECT * 
FROM 
(SELECT *,
ROW_NUMBER() OVER(
PARTITION BY LOWER(email), LOWER(product_name)
ORDER BY order_id ) AS rn
FROM customer_orders) AS subquery
WHERE rn = 1;

-- FINAL CLEAN DATA
WITH cleaned_data AS (
 SELECT 
  order_id,
  -- Clean customer_name 
  initcap(customer_name) AS customer_name, email,
  -- Standardized order_status
  CASE 
   WHEN LOWER(order_status) LIKE '%deliver%' THEN 'Delivered'
   WHEN LOWER(order_status) LIKE '%shipped%' THEN 'Shipped'
   WHEN LOWER(order_status) LIKE '%returned%' THEN 'Returned'
   WHEN LOWER(order_status) LIKE '%refunded%' THEN 'Refunded'
   WHEN LOWER(order_status) LIKE '%pending%' THEN 'Pending'
   ELSE 'Others'
  END AS cleaned_order_status,
   -- Standardized product_name
   CASE 
WHEN LOWER(product_name) LIKE '%google pixel%' THEN 'Google Pixel'
WHEN LOWER(product_name) LIKE '%samsung galaxy s22%' THEN 'Samsung Galaxy S22'
WHEN LOWER(product_name) LIKE '%iphone 14%' THEN 'Iphone 14'
WHEN LOWER(product_name) LIKE '%apple watch%' THEN 'Apple Watch'
WHEN LOWER(product_name) LIKE '%macbook pro%' THEN 'Macbook Pro'
ELSE 'Others'
END AS cleaned_product_name, 
-- Clean quantity
CASE WHEN quantity = 'two' THEN 2
ELSE CAST(quantity AS UNSIGNED)
END AS cleaned_quantity
FROM customer_orders where customer_name IS NOT NULL
),
deduplicated_data AS (
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY LOWER(email), LOWER(cleaned_product_name)
ORDER BY order_id ) AS rn
FROM cleaned_data),
 
final_table AS (SELECT * FROM deduplicated_data WHERE rn = 1)
SELECT * FROM final_table;
 