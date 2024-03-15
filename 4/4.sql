-- 1.1
SELECT *
FROM employees
WHERE officeCode IN (
	SELECT officeCode
	FROM offices
	WHERE country = 'USA'
);

-- 1.2
SELECT customerNumber
FROM customers
WHERE customerNumber = (
	SELECT customerNumber
	FROM payments
	ORDER BY amount DESC
	LIMIT 1
);

-- 1.3
SELECT customerNumber
FROM payments
WHERE amount > (
	SELECT AVG(amount)
	FROM payments
);

-- 1.4
SELECT customerName
FROM customers
WHERE customerNumber NOT IN (
	SELECT customerNumber
	FROM orders
);

-- 1.5
SELECT
    max,
    min,
    ROUND(avg) avg
FROM (
	SELECT
		MAX(quantityOrdered) AS max,
		MIN(quantityOrdered) AS min,
		AVG(quantityOrdered) AS avg
	FROM orderdetails
) AS sq;

-- 1.6
SELECT *
FROM products
WHERE buyPrice > (
	SELECT AVG(buyPrice)
	FROM products p2
	WHERE p2.productLine = products.productLine
);

-- 1.7
SELECT orderNumber
FROM orders
WHERE orderNumber IN (
	SELECT orderNumber
	FROM orderdetails
	GROUP BY orderNumber
	HAVING SUM(quantityOrdered * priceEach) > 60000
);

-- 1.8
SELECT customerNumber
FROM orders
WHERE orderNumber IN (
    SELECT orderNumber
    FROM orderdetails
    GROUP BY orderNumber
    HAVING SUM(quantityOrdered * priceEach) > 60000
);

-- 1.9
SELECT productCode
FROM (
	SELECT productCode, SUM(quantityOrdered * priceEach) sum
	FROM orderdetails
	NATURAL JOIN orders
	WHERE YEAR(orderDate) = '2003'
	GROUP BY productCode
	ORDER BY sum DESC
) sq
LIMIT 5;

-- 1.10
SELECT productCode, productName
FROM (
	SELECT productCode, productName, SUM(quantityOrdered * priceEach) sum
	FROM orderdetails
	NATURAL JOIN orders
	NATURAL JOIN products
	WHERE YEAR(orderDate) = '2003'
	GROUP BY productCode
	ORDER BY sum DESC
) sq
LIMIT 5;

-- 2.1
SELECT customerNumber
FROM customers
WHERE EXISTS (
	SELECT 1
	FROM orders
	WHERE orders.customerNumber = customers.customerNumber
);

-- 2.2
SELECT customerNumber
FROM customers
WHERE NOT EXISTS (
	SELECT 1
	FROM orders
	WHERE orders.customerNumber = customers.customerNumber
);

-- 2.3
SELECT customerNumber
FROM customers
WHERE EXISTS (
	SELECT 1
	FROM customers c
	WHERE c.city = "San Francisco" AND customers.customerNumber = c.customerNumber
);

-- 2.4
UPDATE employees
SET extension = CONCAT(extension, '1')
WHERE EXISTS (
	SELECT 1
	FROM offices
	WHERE offices.officeCode = employees.officeCode
		AND city = 'San Francisco'
);

-- 2.5
CREATE TABLE customers_archive
LIKE customers;

INSERT INTO customers_archive
SELECT *
FROM customers
WHERE NOT EXISTS (
	SELECT 1
	FROM orders
	WHERE orders.customerNumber = customers.customerNumber
);

-- 2.6
-- forign key constraint fails
DELETE FROM customers
WHERE EXISTS (
	SELECT 1
	FROM customers_archive
);

-- 2.7
-- explain absolutely identical -_-
SELECT customerNumber
FROM customers
WHERE EXISTS (
	SELECT 1
	FROM orders
	WHERE customers.customerNumber = orders.customerNumber
);

SELECT customerNumber
FROM customers
WHERE customerNumber IN (
	SELECT customerNumber
	FROM orders
);

-- 2.8
SELECT employeeNumber
FROM employees
WHERE officeCode IN (
    SELECT officeCode 
    FROM offices
    WHERE city = 'San Francisco'
);

-- 3.1
SELECT firstName, lastName
FROM employees
UNION
SELECT contactFirstName, contactLastName
FROM customers

SELECT CONCAT(firstName, " ", lastName) full_name
FROM employees
UNION
SELECT CONCAT(contactFirstName, " ", contactLastName) full_name
FROM customers

SELECT 
  CONCAT(firstName, " ", lastName) full_name, 
  "сотрудник" type
FROM employees
UNION
SELECT 
    CONCAT(contactFirstName, " ", contactLastName), 
    "клиент" type
FROM customers

-- 3.2
-- список клиентов ничего не оплачивавших
SELECT customerNumber
FROM customers
LEFT JOIN payments USING (customerNumber)
WHERE payments.customerNumber IS NULL;

-- товары которые никто не заказывал
SELECT productCode
FROM products
LEFT JOIN orderdetails USING (productCode)
WHERE orderdetails.productCode IS NULL;

-- 3.3
-- клиенты сделавшие хотябы 1 заказ
SELECT DISTINCT customerNumber
FROM customers
WHERE customerNumber IN (SELECT customerNumber FROM orders);

-- товары которые заказывали
SELECT DISTINCT productCode
FROM orderdetails
WHERE productCode IN (SELECT productCode FROM products);
