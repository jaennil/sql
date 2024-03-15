-- 1.1
SELECT CONCAT(firstName, ' ', lastName) AS full_name
FROM employees;

-- 1.2
SELECT CONCAT(lastName, ' ', firstName) full_name
FROM employees
ORDER BY full_name;

-- 1.3
SELECT orderNumber
FROM orderdetails
GROUP BY orderNumber
HAVING SUM(priceEach * quantityOrdered) > 60000;

-- 1.4
SELECT firstName, lastName
FROM employees
ORDER BY lastName;

-- 1.5
SELECT customerNumber, customerName, COUNT(orderNumber)
FROM customers
NATURAL JOIN orders
GROUP BY customerNumber, customerName
ORDER BY customerName;

-- 1.6
SELECT
	products.productName,
	products.productCode,
	productlines.productLine
FROM products
INNER JOIN productlines USING(productLine);

-- 1.7
SELECT orderNumber,
	status,
	SUM(quantityOrdered * priceEach) sum
FROM orders
JOIN orderdetails USING(orderNumber)
GROUP BY orders.orderNumber;

-- 1.8
SELECT *
FROM orders
JOIN orderdetails USING(orderNumber)
JOIN products USING(productCode)
ORDER BY orderNumber, productCode;

-- 1.9
SELECT *
FROM orders
JOIN orderdetails USING(orderNumber)
JOIN customers USING(customerNumber)
JOIN products USING(productCode)
ORDER BY orderNumber, productCode;

-- 1.10
SELECT orders.*
FROM orders
NATURAL JOIN orderdetails
NATURAL JOIN products
WHERE productCode = 'S10_1678' AND priceEach < MSRP;

-- 1.11
SELECT customers.*, orderNumber
FROM customers
LEFT JOIN orders USING(customerNumber);

-- 1.12
SELECT customers.*
FROM customers
LEFT JOIN orders USING(customerNumber)
WHERE orderNumber IS NULL;

-- 1.13
SELECT employees.*, payments.*
FROM employees
JOIN customers ON employeeNumber = salesRepEmployeeNumber
JOIN payments USING(customerNumber);

-- 1.14
SELECT *
FROM orders
JOIN orderdetails
ON orderdetails.orderNumber = 10123;

-- 1.15
SELECT *
FROM customers
RIGHT JOIN employees ON employeeNumber = salesRepEmployeeNumber
ORDER BY employeeNumber;

-- 1.16
SELECT employees.*
FROM employees
LEFT JOIN customers ON employeeNumber = salesRepEmployeeNumber
WHERE customerNumber IS NULL
ORDER BY employeeNumber;

-- 1.17

-- 1.18
SELECT e.firstName employeeName, m.firstName managerName
FROM employees e
JOIN employees m ON e.reportsTo = m.employeeNumber;

-- 1.19
SELECT e.firstName employeeName, m.firstName managerName
FROM employees e
LEFT JOIN employees m ON e.reportsTo = m.employeeNumber;

-- 1.20
SELECT firstName
FROM employees
WHERE jobTitle = 'President';

-- 1.21
SELECT
  c1.customerName,
  c2.customerName,
  c1.city
FROM customers c1
INNER JOIN customers c2 ON c1.city = c2.city
ORDER BY c1.city;

-- 2.1
SELECT DISTINCT status
FROM orders;

-- 2.2
SELECT status
FROM orders
GROUP BY status;

-- 2.3
SELECT status, COUNT(*)
FROM orders
GROUP BY status;

-- 2.4
SELECT status, SUM(quantityOrdered * priceEach) sum
FROM orders
NATURAL JOIN orderdetails
GROUP BY status;

-- 2.5
SELECT
  orderNumber,
  SUM(quantityOrdered * priceEach) sum
FROM orderdetails
GROUP BY orderNumber;

-- 2.6
SELECT YEAR(orderDate) year,
	SUM(quantityOrdered * priceEach) sum
FROM orders
NATURAL JOIN orderdetails
WHERE status = 'Shipped'
GROUP BY year;

-- 2.7
SELECT YEAR(orderDate) year,
	SUM(quantityOrdered * priceEach) sum
FROM orders
NATURAL JOIN orderdetails
WHERE status = 'Shipped'
GROUP BY year
HAVING year > 2003;

-- 2.8
SELECT status, SUM(quantityOrdered) products_amount
FROM orders
NATURAL JOIN orderdetails
GROUP BY status
ORDER BY products_amount DESC;

-- 2.9 
SELECT state
FROM customers
GROUP BY state;

SELECT DISTINCT state
FROM customers;

-- 2.10
CREATE TABLE sales
SELECT
	productLine,
	YEAR(orderDate) orderYear,
	SUM(quantityOrdered * priceEach) orderValue
FROM
	orderdetails
INNER JOIN orders USING (orderNumber)
INNER JOIN products USING (productCode)
GROUP BY productLine, YEAR(orderDate);

SELECT *
FROM sales;

SELECT
	productline,
	SUM(orderValue) sum
FROM sales
GROUP BY productline;

-- 2.11
SELECT
	SUM(orderValue) sum
FROM
	sales;

-- 2.12
SELECT
	productline,
	SUM(orderValue) sum
FROM sales
GROUP BY productline
UNION ALL
SELECT
	NULL,
	SUM(orderValue) sum
FROM sales;

-- 2.13
SELECT
	productline,
	SUM(orderValue) sum
FROM sales
GROUP BY productline
WITH ROLLUP;

-- 2.14
SELECT
	productline,
	orderYear,
	SUM(orderValue) sum
FROM sales
GROUP BY orderYear, productline
WITH ROLLUP;

-- 2.15
SELECT
	productline,
	orderYear,
	SUM(orderValue) sum
FROM sales
GROUP BY productline, orderYear
WITH ROLLUP;

-- 2.16
SELECT
	orderYear,
	productLine,
	SUM(orderValue) totalOrderValue,
	GROUPING(orderYear),
	GROUPING(productLine)
FROM
	sales
GROUP BY
	orderYear,
	productline
WITH ROLLUP;

-- 2.17
SELECT
	IF(GROUPING(orderYear),
		'All Years',
		orderYear) orderYear,
	IF(GROUPING(productLine),
		'All Product Lines',
		productLine) productLine,
	SUM(orderValue) totalOrderValue
FROM
	sales
GROUP BY
	orderYear,
	productline
WITH ROLLUP;
