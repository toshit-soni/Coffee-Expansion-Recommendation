USE monday_coffee_db;

-- Total records
SELECT COUNT(*) FROM sales;
SELECT COUNT(*) FROM cities;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;

-- Null values
SELECT 
	SUM(CASE WHEN sale_id IS NULL THEN 1 ELSE 0 END) id_nulls,
	SUM(CASE WHEN sale_date IS NULL THEN 1 ELSE 0 END) date_nulls,
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) product_nulls,
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) customer_nulls,
	SUM(CASE WHEN total IS NULL THEN 1 ELSE 0 END) total_nulls,
	SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) rating_nulls
FROM sales;

SELECT 
	SUM(CASE WHEN city_id IS NULL THEN 1 ELSE 0 END) id_nulls,
	SUM(CASE WHEN city_name IS NULL THEN 1 ELSE 0 END) city_nulls,
	SUM(CASE WHEN population IS NULL THEN 1 ELSE 0 END) population_nulls,
	SUM(CASE WHEN estimated_rent IS NULL THEN 1 ELSE 0 END) rent_nulls,
	SUM(CASE WHEN city_rank IS NULL THEN 1 ELSE 0 END) rank_nulls
FROM cities;

SELECT 
	SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) id_nulls,
	SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) name_nulls,
	SUM(CASE WHEN city_id IS NULL THEN 1 ELSE 0 END) city_nulls
FROM customers;

SELECT 
	SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) id_nulls,
	SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) product_nulls,
	SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) price_nulls
FROM products;

-- Duplicates
SELECT 
	sale_id, sale_date, product_id, customer_id, total, rating, 
    COUNT(*) AS cnt
FROM sales
GROUP BY sale_id, sale_date, product_id, customer_id, total, rating
HAVING cnt > 1;

SELECT 
	city_id, city_name, population, estimated_rent, city_rank,
    COUNT(*) AS cnt
FROM cities
GROUP BY city_id, city_name, population, estimated_rent, city_rank
HAVING cnt > 1;

SELECT 
	customer_id, customer_name, city_id, 
    COUNT(*) AS cnt
FROM customers
GROUP BY customer_id, customer_name, city_id
HAVING cnt > 1;

SELECT 
	product_id, product_name, price, 
    COUNT(*) AS cnt
FROM products
GROUP BY product_id, product_name, price
HAVING cnt > 1;