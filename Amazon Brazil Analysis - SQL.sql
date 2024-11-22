                  Amazon Brazil Analysis (SQL)

1. To simplify its financial reports, Amazon India needs to standardize payment values. 
Round the average payment values to integer (no decimal) for each payment type and 
display the results sorted in ascending order.

SELECT payment_type, ROUND(AVG(payment_value)) AS rounded_avg_payment 
FROM amazon_brazil."Payments"
WHERE payment_value > 0
GROUP BY payment_type
ORDER BY rounded_avg_payment ASC;


2. To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type.
Calculate the percentage of total orders for each payment type, 
rounded to one decimal place, and display them in descending order

SELECT payment_type, ROUND((COUNT(payment_type)*100.0)/(SELECT COUNT(DISTINCT order_id) FROM amazon_brazil."Payments"), 1) 
  AS percentage_orders
  FROM amazon_brazil."Payments" 
WHERE payment_value > 0
GROUP BY payment_type
ORDER BY percentage_orders DESC;

3. Amazon India seeks to create targeted promotions for products within specific price ranges. 
Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in 
their name. Display these products, sorted by price in descending order.
Output: product_id, price

SELECT pd.product_id, ROUND(oi.price, 0) AS price FROM amazon_brazil."Product" pd
JOIN amazon_brazil."Order_Items" oi ON pd.product_id = oi.product_id
WHERE oi.price BETWEEN '100' AND '500' AND pd.product_category_name LIKE '%smart%'
ORDER BY oi.price DESC;


4. To identify seasonal sales patterns, Amazon India needs to focus on the most successful 
months. Determine the top 3 months with the highest total sales value, rounded to the 
nearest integer.
Output: month, total_sales

SELECT ROUND(SUM(pt.payment_value)) AS total_sales, To_CHAR(o.order_purchase_timestamp, 'Month') as months 
FROM amazon_brazil."Payments" pt
JOIN amazon_brazil."Orders" o ON pt.order_id = o.order_id
GROUP BY months
ORDER BY total_sales DESC
LIMIT 3;

5. Amazon India is interested in product categories with significant price variations. 
Find categories where the difference between the maximum and minimum product prices 
is greater than 500 BRL.
Output: product_category_name, price_difference

SELECT pd.product_category_name, MAX(oi.price) - MIN(oi.price) AS price_difference 
FROM amazon_brazil."Product" pd
JOIN amazon_brazil."Order_Items" oi ON pd.product_id = oi.product_id
GROUP BY pd.product_category_name
HAVING MAX(oi.price) - MIN(oi.price) > 500
ORDER BY price_difference DESC;

6. To enhance the customer experience, Amazon India wants to find which payment types 
have the most consistent transaction amounts. Identify the payment types with the least 
variance in transaction amounts, sorting by the smallest standard deviation first.
Output: payment_type, std_deviation

SELECT payment_type, STDDEV(payment_value) AS std_deviation 
FROM amazon_brazil."Payments" 
WHERE payment_value > 0
GROUP BY payment_type
ORDER BY std_deviation;

7. Amazon India wants to identify products that may have incomplete name in order to 
fix it from their end. Retrieve the list of products where the product category name 
is missing or contains only a single character.
Output: product_id, product_category_name

SELECT product_id, product_category_name FROM amazon_brazil."Product"
WHERE product_category_name IS NULL OR product_category_name LIKE '_' 
ORDER BY product_category_name;

Analysis - II
1. Amazon India wants to understand which payment types are most popular across different 
order value segments (e.g., low, medium, high). Segment order values into 
three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. 
Calculate the count of each payment type within these ranges and display the results in 
descending order of count
Output: order_value_segment, payment_type, count

SELECT
 CASE
   WHEN payment_value < 200 THEN 'LOW'
   WHEN payment_value BETWEEN 200 AND 1000 THEN 'MEDIUM'
   ELSE 'HIGH'
 END AS order_value_segment,
payment_type, COUNT(payment_type) AS Payment_Count
FROM amazon_brazil."Payments"
GROUP BY payment_type, order_value_segment
ORDER BY Payment_Count DESC;

-- 2. Amazon India wants to analyse the price range and average price for each product category. 
-- Calculate the minimum, maximum, and average price for each category, and list them in descending 
-- order by the average price.
-- Output: product_category_name, min_price, max_price, avg_price

SELECT pd.product_category_name, ROUND(MIN(oi.price), 2) AS min_price, ROUND(MAX(oi.price), 2) AS max_price,
ROUND(AVG(oi.price), 2) AS avg_price
FROM amazon_brazil."Product" pd
JOIN amazon_brazil."Order_Items" oi ON pd.product_id = oi.product_id
GROUP BY pd.product_category_name
ORDER BY avg_price DESC;

3. Amazon India wants to identify the customers who have placed multiple orders over time. 
Find all customers with more than one order, and display their customer unique IDs 
along with the total number of orders they have placed.
Output: customer_unique_id, total_orders

SELECT cs.customer_unique_id, COUNT(o.order_id) AS total_orders FROM amazon_brazil."Orders" o
JOIN amazon_brazil."Customers" cs ON o.customer_id = cs.customer_id
GROUP BY cs.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY total_orders DESC


4. Amazon India wants to categorize customers into different types 
('New – order qty. = 1' ;  'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4) 
based on their purchase history. Use a temporary table to define these categories and join 
it with the customers table to update and display the customer types.
Output: customer_id, customer_type

WITH ct as
(SELECT o.customer_id,
  CASE 
   WHEN COUNT(order_id) = 1 THEN 'NEW'
   WHEN COUNT(order_id) BETWEEN 2 AND 4 THEN 'RETURNING'
   WHEN COUNT(order_id) > 4 THEN 'LOYAL'
   ELSE 'NO ORDER'
  END AS customer_type
 FROM amazon_brazil."Orders" o
 GROUP BY customer_id
) 
SELECT cs.customer_id, ct.customer_type  
FROM amazon_brazil."Customers" cs
LEFT JOIN ct on cs.customer_id = ct.customer_id

5. Amazon India wants to know which product categories generate the most revenue. 
Use joins between the tables to calculate the total revenue for each product category. 
Display the top 5 categories.
Output: product_category_name, total_revenue

SELECT pd.product_category_name, SUM(oi.price) AS total_revenue 
FROM amazon_brazil."Product" pd
JOIN amazon_brazil."Order_Items" oi ON pd.product_id = oi.product_id
GROUP BY pd.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;

ANALYSIS III

1. The marketing team wants to compare the total sales between different seasons. 
Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) 
based on order purchase dates, and display the results. Spring is in the months of 
March, April and May. Summer is from June to August and Autumn is between September and November 
and rest months are Winter. 
Output: season, total_sales


SELECT
 CASE
   WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
   WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
   WHEN EXTRACT(MONTH FROM order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
   ELSE 'Winter'
 END AS season,
SUM(pt.payment_value) AS total_sales
FROM amazon_brazil."Orders" O
JOIN amazon_brazil."Payments" pt ON o.order_id = pt.order_id
GROUP BY season;


2. The inventory team is interested in identifying products that have sales volumes above the 
overall average. Write a query that uses a subquery to filter products with a total quantity 
sold above the average quantity.
Output: product_id, total_quantity_sold

WITH coi AS (
 SELECT product_id, COUNT(order_item_id) AS total_quantity_sold 
 FROM amazon_brazil."Order_Items"
 GROUP BY product_id
)
SELECT product_id, total_quantity_sold FROM coi 
WHERE total_quantity_sold > (
 SELECT AVG(total_quantity_sold) FROM coi 
)
ORDER BY total_quantity_sold DESC;

3. To understand seasonal sales patterns, the finance team is analysing the monthly revenue 
trends over the past year (year 2018). Run a query to calculate total revenue generated 
each month and identify periods of peak and low sales. Export the data to Excel and create a 
graph to visually represent revenue changes across the months. 
Output: month, total_revenue

SELECT TO_CHAR(DATE_TRUNC('MONTH', o.order_purchase_timestamp), 'YYYY-MM') AS month, 
 SUM(pt.payment_value) AS total_revenue
FROM amazon_brazil."Orders" o
JOIN amazon_brazil."Payments" pt ON o.order_id = pt.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY month
ORDER BY month;

4. A loyalty program is being designed for Amazon India. Create a segmentation based on 
purchase frequency: ‘Occasional’ for customers with 1-2 orders, ‘Regular’ for 3-5 orders, 
and ‘Loyal’ for more than 5 orders. Use a CTE to classify customers and their count and 
generate a chart in Excel to show the proportion of each segment.
Output: customer_type, count

WITH cust_det AS(
 SELECT 
   CASE
     WHEN COUNT(order_id) BETWEEN 1 AND 2 THEN 'Occasional'
	 WHEN COUNT(order_id) BETWEEN 3 AND 5 THEN 'Regular'
	 ELSE 'Loyal'
   END AS customer_type,
  COUNT(order_id) AS count
 FROM amazon_brazil."Orders"
GROUP BY customer_id
)
SELECT customer_type, COUNT(*) AS count 
FROM cust_det
GROUP BY customer_type
ORDER BY count DESC;


5. Amazon wants to identify high-value customers to target for an exclusive rewards program. 
You are required to rank customers based on their average order value (avg_order_value) to 
find the top 20 customers.
Output: customer_id, avg_order_value, and customer_rank

WITH Top_20 AS(
	SELECT o.customer_id, ROUND(AVG(pt.payment_value),2) AS avg_order_value
	FROM amazon_brazil."Orders" o
	JOIN amazon_brazil."Payments" pt ON o.order_id = pt.order_id
	GROUP BY o.customer_id	
)
SELECT customer_id, avg_order_value, 
	RANK() OVER(ORDER BY avg_order_value DESC) AS "customer_rank"
FROM Top_20
ORDER BY avg_order_value DESC
LIMIT 20;


6. Amazon wants to analyze sales growth trends for its key products over their lifecycle. 
Calculate monthly cumulative sales for each product from the date of its first sale. 
Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.
Output: product_id, sale_month, and total_sales

WITH growth_trends AS(
	SELECT oi.product_id, 
	 TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS sale_month,
	 SUM(oi.price) AS monthly_sales
	 FROM amazon_brazil."Orders" o
	JOIN amazon_brazil."Order_Items" oi ON o.order_id = oi.order_id
	GROUP BY oi.product_id, sale_month 
)
SELECT product_id, sale_month, monthly_sales,
SUM(monthly_sales) OVER(PARTITION BY product_id ORDER BY sale_month) AS total_sales
FROM growth_trends
ORDER BY product_id, sale_month;


7. To understand how different payment methods affect monthly sales growth, Amazon wants to 
compute the total sales for each payment method and calculate the month-over-month growth rate 
for the past year (year 2018). Write query to first calculate total monthly sales for each 
payment method, then compute the percentage change from the previous month.
Output: payment_type, sale_month, monthly_total, monthly_change.


WITH monthly_sales AS(
 SELECT pt.payment_type, 
 TO_CHAR(DATE_TRUNC('month', o.order_purchase_timestamp), 'YYYY-MM') AS sale_month,
 SUM(payment_value) AS monthly_total
 FROM amazon_brazil."Payments" pt 
 JOIN amazon_brazil."Orders" o on pt.order_id = o.order_id
 WHERE DATE_PART('Year', o.order_purchase_timestamp) = 2018 AND pt.payment_value > 0
 GROUP BY pt.payment_type, sale_month
)
 SELECT payment_type, sale_month, monthly_total,
 ROUND(((monthly_total - LAG(monthly_total) OVER(PARTITION BY payment_type ORDER BY sale_month))*100/
 (LAG(monthly_total) OVER(PARTITION BY payment_type ORDER BY sale_month))), 2) || '%' AS monthly_change 
 FROM monthly_sales
 ORDER BY payment_type, sale_month;
  
 



