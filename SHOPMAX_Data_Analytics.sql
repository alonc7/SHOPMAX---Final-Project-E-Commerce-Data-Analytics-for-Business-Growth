--CREATE DATABASE SHOPMAX;
--USE SHOPMAX;

CREATE TABLE Sales (
    order_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) DEFAULT 0,
    total_sales AS (quantity * price - discount) PERSISTED
);


CREATE TABLE Customers(
 customer_id INT PRIMARY KEY,
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(100),
    signup_date DATE,
    region NVARCHAR(50),
    age INT
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    category NVARCHAR(50),
    subcategory NVARCHAR(50),
    product_name NVARCHAR(100),
    stock_quantity INT,
    supplier_id INT
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name NVARCHAR(100),
    contact_email NVARCHAR(100),
    region NVARCHAR(50)
);
EXEC sp_help 'Sales';
EXEC sp_help 'Customers';
EXEC sp_help 'Products';
EXEC sp_help 'Suppliers';

INSERT INTO Sales (order_id, product_id, customer_id, order_date, quantity, price, discount)
VALUES 
(1, 101, 201, '2024-01-15', 2, 250.00, 20.00),
(2, 102, 202, '2024-01-16', 1, 500.00, 50.00),
(3, 103, 203, '2024-01-17', 3, 150.00, 0.00),
(4, 101, 204, '2024-01-18', 1, 250.00, 10.00),
(5, 104, 205, '2024-01-19', 5, 100.00, 25.00);

INSERT INTO Customers (customer_id, first_name, last_name, email, signup_date, region, age)
VALUES 
(201, 'John', 'Doe', 'john.doe@example.com', '2023-12-01', 'North', 35),
(202, 'Jane', 'Smith', 'jane.smith@example.com', '2023-12-02', 'West', 28),
(203, 'Emily', 'Johnson', 'emily.johnson@example.com', '2023-12-03', 'East', 40),
(204, 'Michael', 'Brown', 'michael.brown@example.com', '2023-12-04', 'South', 30),
(205, 'Sarah', 'Davis', 'sarah.davis@example.com', '2023-12-05', 'Central', 45);


INSERT INTO Products (product_id, category, subcategory, product_name, stock_quantity, supplier_id)
VALUES 
(101, 'Electronics', 'Mobile', 'Smartphone A', 50, 301),
(102, 'Electronics', 'Laptop', 'Laptop B', 20, 302),
(103, 'Electronics', 'Accessories', 'Headphones C', 100, 303),
(104, 'Electronics', 'Mobile', 'Smartphone D', 30, 304),
(105, 'Electronics', 'TV', 'Smart TV E', 10, 305);


INSERT INTO Suppliers (supplier_id, supplier_name, contact_email, region)
VALUES 
(301, 'Tech Supplies Inc.', 'contact@techsupplies.com', 'North'),
(302, 'Gadgets Pro Ltd.', 'info@gadgetspro.com', 'West'),
(303, 'Audio World', 'support@audioworld.com', 'East'),
(304, 'Mobile Hub', 'sales@mobilehub.com', 'South'),
(305, 'TV Experts', 'service@tvexperts.com', 'Central');


-- Check for Missing Values
SELECT * FROM Sales;
SELECT * FROM Customers;
SELECT * FROM Products;
SELECT * FROM Suppliers;

--Check for Missing Values
SELECT * FROM Sales
WHERE product_id IS NULL 
   OR customer_id IS NULL
   OR order_date IS NULL
   OR quantity IS NULL
   OR price IS NULL
   OR discount IS NULL;

SELECT * FROM Customers
WHERE first_name IS NULL 
   OR last_name IS NULL
   OR email IS NULL
   OR signup_date IS NULL;

SELECT * FROM Products
WHERE category IS NULL 
   OR product_name IS NULL
   OR stock_quantity IS NULL
   OR supplier_id IS NULL;

SELECT * FROM Suppliers
WHERE supplier_name IS NULL
   OR contact_email IS NULL;

--Check for Duplicates
SELECT order_id, COUNT(*) 
FROM Sales
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT customer_id,COUNT(*) as customer_count
FROM Customers
group by customer_id
having count(*)>1;

SELECT product_id,COUNT(*) as count_of_prod
FROM Products
GROUP BY product_id
HAVING COUNT(*) >1;

SELECT supplier_id,COUNT(*) as count_of_supplier
FROM Suppliers
GROUP BY supplier_id
HAVING COUNT(*)>1;

--Check Data Consistency
--Ensure product_id in Sales exists in Products:
SELECT S.product_id
FROM Sales s
LEFT JOIN Products p on s.product_id = p.product_id
WHERE P.product_id IS NULL;

--Ensure customer_id in Sales exists in Customers:
SELECT S.customer_id 
FROM Sales s
LEFT JOIN Customers c ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

--Ensure supplier_id in Products exists in Suppliers
SELECT p.supplier_id
from Products p
LEFT JOIN Suppliers s on p.supplier_id = s.supplier_id
WHERE s.supplier_id IS NULL;

ALTER TABLE Sales
ADD total_profit AS (quantity * (price * 0.3) - discount) PERSISTED;

SELECT TOP 10 order_date, signup_date FROM Sales JOIN Customers ON Sales.customer_id = Customers.customer_id;

ALTER TABLE Customers
ADD age_group NVARCHAR(20);

UPDATE Customers
SET age_group = CASE
	WHEN age<25 THEN 'Under 25'
	WHEN age BETWEEN 25 and 34 THEN '25-34'
	WHEN age BETWEEN 35 and 44 THEN '35-44'
	WHEN age >= 45 THEN '45+'
	ELSE 'Unknown'
END;

--Validate Stock Levels
SELECT p.product_name, p.stock_quantity, SUM(s.quantity) AS total_sold
FROM Products p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_name , p.stock_quantity
HAVING p.stock_quantity < SUM(s.quantity)

--Exploratory Data Analysis (EDA).
--This phase will focus on uncovering trends and answering key business questions.

--Calculate total revenue for each month:
SELECT 
	year(order_date) AS year,
	MONTH(order_date) AS month,
	SUM(total_sales) AS monthly_revenue
from sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

--Find out how much each product category contributes to total revenue:
SELECT
	p.category,
	SUM(s.total_sales) AS category_revenue
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY category_revenue DESC;

--Calculate the average order value:
SELECT AVG(total_sales) AS average_order_value
FROM Sales;

--Group customers by signup month and calculate their retention:

SELECT 
	YEAR(c.signup_date) AS signup_year,
	MONTH(c.signup_date) AS signup_month,
	COUNT(DISTINCT s.customer_id) AS retained_customers,
	COUNT(DISTINCT c.customer_id) AS total_customers,
	(COUNT(DISTINCT s.customer_id) * 1.0 / COUNT(DISTINCT c.customer_id)) * 100 AS retention_rate
FROM Customers c
LEFT JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY YEAR(c.signup_date),MONTH(c.signup_date);

--Find regions with the highest customer activity:
SELECT 
    c.region,
    COUNT(DISTINCT s.customer_id) AS active_customers
FROM Customers c
JOIN Sales s ON c.customer_id = s.customer_id
GROUP BY c.region
ORDER BY active_customers DESC;

-- Top 10 Products by Sales Volume
SELECT TOP 10
    p.product_name,
    SUM(s.quantity) AS total_sold
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_sold DESC;


--Find suppliers with high sales volume and minimal stock-outs:
SELECT 
    sup.supplier_name,
    SUM(s.quantity) AS total_sold,
    MIN(p.stock_quantity) AS min_stock_level
FROM Suppliers sup
JOIN Products p ON sup.supplier_id = p.supplier_id
JOIN Sales s ON p.product_id = s.product_id
GROUP BY sup.supplier_name
ORDER BY total_sold DESC, min_stock_level ASC;

--Products with the Highest Profit Margins
SELECT TOP 10
    p.product_name,
    SUM(s.total_profit) AS total_profit
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_profit DESC;


--Categories with the Highest Margins
SELECT 
    p.category,
    SUM(s.total_profit) AS total_profit
FROM Sales s
JOIN Products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_profit DESC;


-----------------------KPI Calculations
--Revenue Growth Rate
WITH MonthlyRevenue AS (
    SELECT 
        YEAR(order_date) AS year,
        MONTH(order_date) AS month,
        SUM(total_sales) AS revenue
    FROM Sales
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT 
    year,
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,
    ((revenue - LAG(revenue) OVER (ORDER BY year, month)) * 1.0 / NULLIF(LAG(revenue) OVER (ORDER BY year, month), 0)) * 100 AS revenue_growth_rate
FROM MonthlyRevenue;
