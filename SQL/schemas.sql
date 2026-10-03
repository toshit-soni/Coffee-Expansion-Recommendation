-- Monday Coffee Schemas

DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS sales;

CREATE TABLE cities(
	city_id	INT PRIMARY KEY,
    city_name VARCHAR(25),
    population INT,
    estimated_rent DECIMAL(15,2),
    city_rank INT
);

CREATE TABLE products(
	product_id INT PRIMARY KEY,	
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE customers(
	customer_id INT PRIMARY KEY,	
    customer_name VARCHAR(30),
    city_id INT,
    
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES cities(city_id)
);

CREATE TABLE sales(
	sale_id INT PRIMARY KEY,	
    sale_date DATE,
    product_id INT, 
    customer_id	INT, 
    total DECIMAL(15, 2),
    rating INT,
    
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- First, import Data to cities
-- Second, import Data to products
-- Third, import Data to customers
-- Last, import Data to sales

-- End of Schema