USE monday_coffee_db;

SELECT * FROM sales;
SELECT * FROM products;
SELECT * FROM customers;
SELECT * FROM cities;

-- Analysis

-- 1. Coffee consumer count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
	city_name,
    ROUND((population * 0.25) / 1000000, 
    2) AS coffee_consumers_in_millions
FROM cities
ORDER BY coffee_consumers_in_millions DESC;



-- 2. Total revenue from coffee sales
-- What is the total revenue generated from the coffee sales across all cities in last qtr of 2023?

SELECT 
	ct.city_name,
	SUM(s.total) AS total_revenue
FROM sales s JOIN customers c ON s.customer_id = c.customer_id 
JOIN cities ct ON ct.city_id = c.city_id
WHERE YEAR(s.sale_date) = 2023 AND QUARTER(s.sale_date) = 4
GROUP BY ct.city_name
ORDER BY total_revenue DESC;



-- 3. Sales count for each product
-- How many units of each coffee product have been sold?

SELECT 
	p.product_name,
    COUNT(s.sale_id) AS units_sold
FROM products p  LEFT JOIN sales s ON p.product_id = s.product_id
GROUP BY p.product_name
ORDER BY units_sold DESC;



-- 4. Average sales amount per city 
-- What is the avg sales amount per customer in each city?

SELECT 
	ct.city_name,
	SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_customers,
    ROUND( 
		SUM(s.total) / COUNT(DISTINCT s.customer_id), 
	2) AS avg_sales_amt
FROM sales s JOIN customers c ON s.customer_id = c.customer_id
JOIN cities ct ON c.city_id = ct.city_id
GROUP BY ct.city_name
ORDER BY total_revenue DESC;



-- 5. City population and coffee consumers 
-- Provide a list of cities along with their populations and estimated coffee consumers

WITH city_data AS
(
	SELECT 
		city_name,
		ROUND((population * 0.25) / 1000000, 2) AS coffee_consumers_in_millions
	FROM cities
),
customers_data AS
(
	SELECT 
		ct.city_name,
		COUNT(DISTINCT s.customer_id) AS unique_customers
	FROM sales s JOIN customers c ON s.customer_id = c.customer_id
	JOIN cities ct ON c.city_id = ct.city_id
	GROUP BY ct.city_name
)
SELECT 
	c1.city_name,
    c1.coffee_consumers_in_millions,
    c2.unique_customers
FROM city_data c1 JOIN customers_data c2 
ON c1.city_name = c2.city_name;



-- 6. Top selling products by city	
-- What are the Top 3 selling products in each city based on sales volume?
WITH revenue AS(
	SELECT
		ct.city_name,
		p.product_name,
        COUNT(s.sale_id) AS units_sold,
        DENSE_RANK() OVER(PARTITION BY ct.city_name ORDER BY COUNT(s.sale_id) DESC) AS rnk
    FROM 
		sales s JOIN customers c ON s.customer_id = c.customer_id 
		JOIN cities ct ON c.city_id = ct.city_id
        JOIN products p ON s.product_id = p.product_id
    GROUP BY ct.city_name, p.product_name
)
SELECT 
	city_name,
    product_name,
    units_sold
FROM revenue 
WHERE rnk <=3;



-- 7. Customer segmentation by city
-- How many unique customers are there in each city who have purchased coffee products
SELECT 
	ct.city_name, 
    COUNT(DISTINCT s.customer_id) AS unique_customers
FROM 
	cities ct LEFT JOIN customers c ON ct.city_id = c.city_id  
	JOIN sales s ON s.customer_id = c.customer_id 
	JOIN products p ON s.product_id = p.product_id
WHERE lower(p.product_name) LIKE '%coffee%'
GROUP BY ct.city_name
ORDER BY unique_customers DESC;



-- 8. Impact of estimated rent on sales 
-- Find each city and their average sale per customer and avg rent per customer
WITH city_data AS 
(
	SELECT 
		ct.city_name,
		SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS unique_customers,
        ROUND(
			SUM(s.total) / COUNT(DISTINCT s.customer_id),  
		2) AS avg_sale_per_customer
	FROM 
		sales s JOIN customers c ON s.customer_id = c.customer_id 
		JOIN cities ct ON c.city_id = ct.city_id
	GROUP BY ct.city_name
)
SELECT 
	c.city_name, 
    cd.unique_customers,
    cd.avg_sale_per_customer,
    ROUND(c.estimated_rent / cd.unique_customers, 2) AS avg_rent_per_customer
FROM cities c JOIN city_data cd ON c.city_name = cd.city_name
ORDER BY avg_sale_per_customer DESC;



-- 9. Monthly sales growth
-- Calculate the % of growth or decline in sales over different time periods (monthly)
WITH monthly_revenue AS
(
	SELECT 
		ct.city_name,
        YEAR(s.sale_date) AS Year,
        MONTH(s.sale_date) AS Month,
        SUM(total) AS total_revenue
    FROM sales s JOIN customers c ON s.customer_id = c.customer_id
    JOIN cities ct ON c.city_id = ct.city_id
    GROUP BY ct.city_name, year, month
),
prev_revenue AS
(
	SELECT 
		city_name,
        year,
        month,
        total_revenue,
		LAG(total_revenue) OVER(PARTITION BY city_name ORDER BY year, month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT 
	city_name,
	year,
    month,
    total_revenue AS current_month_revenue,
    prev_month_revenue,
    ROUND(
		(total_revenue - prev_month_revenue) * 100 / prev_month_revenue,
	2) AS growth_pct
FROM prev_revenue
WHERE prev_month_revenue IS NOT NULL
ORDER BY city_name, year, month;



-- 10. Market potential analysis 
-- Identify top 3 cities with highest sales
-- Return city name, total sale, total rent, total customers, estimated coffee consumer

WITH city_data AS 
(
	SELECT 
		ct.city_id, 
        SUM(s.total) AS total_revenue,
        COUNT(DISTINCT s.customer_id) AS unique_customers,
        ROUND(
			SUM(s.total) / COUNT(DISTINCT s.customer_id),
        2) AS avg_sale_per_customer
    FROM cities ct LEFT JOIN customers c ON c.city_id = ct.city_id
    JOIN sales s ON s.customer_id = c.customer_id
    GROUP BY city_id
)
SELECT 
	ct.city_name,
	cd.total_revenue,	
	ct.estimated_rent AS total_rent,
	cd.unique_customers,
	ROUND(
		(ct.population * 0.25) / 1000000, 
	2) AS coffee_consumers_in_millions,
    avg_sale_per_customer,
	ROUND(
		ct.estimated_rent / cd.unique_customers,
	2) AS avg_rent_per_customer
FROM city_data cd JOIN cities ct ON cd.city_id = ct.city_id
ORDER BY cd.total_revenue DESC 
LIMIT 3;



-- Key Insights
-- 1. Delhi has the highest coffee consumers (7.75M) followed by Mumbai (5.10M) and Kolkata(3.73M)
-- 2. Luknow (0.95M) and Jaipur (1M) have lowest number of coffee consumers
-- 3. South Indian cities (Pune- 4.3M, Chennai- 3M, Bangalore- 27M) has the highest total revenue among all 
-- 4. Jaipur, despite of less coffee consumers, MondayCoffee has highest customers there - 69.
-- 5. Avg rent per customer is less in Jaipur and high in Bangalore
-- 6. Cold Brew Coffee Pack (6 Bottles), Ground Espresso Coffee (250g), Instant Coffee Powder (100g) are the top 3 highest selling products.
-- 7. During the last quarter of 2023, Pune recorded highest revenue about 4.3M, followed by Chennai- 3M and Bangalore- 27M.



-- Recommedations
-- Top 3 cities for opening new outlets of MondayCoffee are:

-- 1. Pune 
-- Highest total revenue - 1258290
-- Highest avg sale per consumer - 24197
-- Low avg rent - 294
-- 52 unique consumers

-- 2. Delhi 
-- High revenue - 750420
-- 68 unique customers
-- low rent - 330
-- highest coffee consumers - 7.75

-- 3. Jaipur
-- High revenue - 803450
-- low avg rent - 156
-- 69 unique customers 
