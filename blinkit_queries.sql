-- SALES ANALYSIS
-- Top 5 revenue generating products with brand?
SELECT p.product_name,p.brand,SUM(oi.quantity*oi.unit_price) AS revenue
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY product_name,brand
ORDER BY revenue DESC
LIMIT 5;

-- --TOP 5 PRODUCTS BY UNITS SOLD 
SELECT p.product_name,p.brand,SUM(oi.quantity) AS total_units_sold
FROM products p
JOIN order_items oi
ON p.product_id=oi.product_id
GROUP BY p.product_name,p.brand
ORDER BY total_units_sold DESC
LIMIT 5;

-- --WHAT IS OVERALL TOTAL SALES AND AVERAGE MONTHLY SALES 
SELECT (
	SELECT SUM(order_total) FROM orders) AS overall_total_sales,
    (
    SELECT ROUND(AVG(monthly_revenue),2)
    FROM (
    SELECT
    date_format(order_date,'%Y,%m') AS sales_month,
    SUM(order_total) AS monthly_revenue FROM orders
    GROUP BY sales_month
    ) AS monthly_sales
    ) AS avg_monthly_sales;
    
-- --INVENTORY ANALYSIS 
-- HIGHEST DAMAGED STOCK FOR EACH YEAR WITH PRODUCT NAME AND BRAND
WITH yearlydamagedstock AS (
	SELECT 
		YEAR(i.date) AS year,
        SUM(i.damaged_stock) AS total_damaged_stock,p.product_name,p.brand
	FROM inventory i
    JOIN products p 
    ON i.product_id=p.product_id
    GROUP BY year,p.product_name,p.brand
    ORDER BY total_damaged_stock DESC),
RankedDamagedStock AS (
	SELECT year,total_damaged_stock,product_name,brand,
    ROW_NUMBER() OVER(PARTITION BY year ORDER BY total_damaged_stock DESC) AS rn 
    FROM yearlydamagedstock
    )
SELECT year,total_damaged_stock,product_name,brand
FROM RankedDamagedStock
WHERE rn=1
ORDER BY total_damaged_stock DESC;

-- DELIVERY ANALYSIS
-- WHAT IS THE AVERAGE DELIVERY TIME FOR ALL ORDERS
SELECT AVG(delivery_time_minutes) AS avg_delivery_time
FROM delivery_performance;

-- COUNT DELIVERIES BASED ON DELIVERY STATUS
SELECT delivery_status,COUNT(*) AS total_deliveries
FROM delivery_performance
GROUP BY delivery_status
ORDER BY total_deliveries DESC;

-- WHAT ARE THE MOST COMMON REASONS FOR DELIVERY DELAYS
SELECT reasons_if_delayed,COUNT(*) AS delay_count
FROM delivery_performance
WHERE delivery_status='slightly delayed' OR delivery_status='significantly delyed'
GROUP BY reasons_if_delayed
ORDER BY delay_count DESC;

-- CUSTOMER ANALYSIS 
-- TOP 3 CUSTOMERS BY TOTAL REVENUE, AND HOW MANY ORDERS HAVE THEY PLACED
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS total_orders,
SUM(order_total) AS total_revenue
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
GROUP BY c.customer_id,c.customer_name
ORDER BY total_revenue DESC
LIMIT 3;

-- WHICH CUSTOMERS SEGMENT PLACES THE HIGHEST NUMBER OF ORDERS 
SELECT c.customer_segment,COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o 
ON c.customer_id=o.customer_id
GROUP BY c.customer_segment
ORDER BY total_orders DESC;

-- FEEDBACK ANALYSIS
-- WHAT IS AVERAGE RATING OVERALL
SELECT ROUND(AVG(rating),2) AS average_rating
FROM customer_feedback;

-- WHICH FEEDBACK CATEGORIES ARE RECEIVING THE MOST POSITIVE CUSTOMER FEEDBACK
SELECT feedback_category,COUNT(sentiment) AS number_of_positive_feedback
FROM customer_feedback
WHERE sentiment='positive'
GROUP BY feedback_category
ORDER BY number_of_positive_feedback DESC;

-- COUNT OF FEEDBACK ENTRIES BY SENTIMENT TYPE (positive,neutral,negative)
SELECT sentiment,COUNT(*) AS feedback_count
FROM customer_feedback
GROUP BY sentiment
ORDER BY feedback_count DESC;

-- MARKETING ANALYSIS 
-- WHICH MARKETING CMAPAIGN GENERATED THE MOST REVENUE
SELECT campaign_name,SUM(revenue_generated) AS total_revenue_generated
FROM marketing_performance
GROUP BY campaign_name
ORDER BY total_revenue_generated DESC
LIMIT 1;

-- WHICH CAMPAIGN ACHIEVED THE BEST ROAS(RETURN ON AD SPEND)
SELECT campaign_name,
ROUND(SUM(revenue_generated)/SUM(spend),2)AS overall_roas
FROM marketing_performance
GROUP BY campaign_name
ORDER BY overall_roas DESC
LIMIT 1;