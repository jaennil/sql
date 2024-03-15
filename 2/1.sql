-- 1
SELECT lastName
FROM employees;

-- 2
SELECT lastName, firstName, jobTitle
FROM employees;

-- 3
SELECT * FROM employees;

-- 4
SELECT contactLastName, contactFirstName
FROM customers
ORDER BY contactLastName ASC;

-- 5
SELECT contactLastName, contactFirstName
FROM customers
ORDER BY contactLastName DESC;

-- 6
SELECT contactLastName, contactFirstName
FROM customers

-- 7
SELECT orderNumber,
	productCode,
	quantityOrdered,
	priceEach,
	(quantityOrdered * priceEach) AS subtotal
FROM orderdetails
ORDER BY subtotal DESC;

-- 8
SELECT orderNumber
FROM orders
ORDER BY FIELD(
	status,
	'In Process',
	'On Hold',
	'Canceled',
	'Resolved',
	'Disputed',
	'Shipped'
);

-- 9
SELECT e.lastName
FROM employees e
LEFT JOIN employees m ON e.reportsTo = m.employeeNumber
ORDER BY m.employeeNumber ASC;

-- 10
SELECT e.lastName FROM employees e
LEFT JOIN employees m ON e.reportsTo = m.employeeNumber
ORDER BY m.employeeNumber DESC;

-- 11
SELECT lastName, firstName
FROM employees
WHERE jobTitle = 'Sales Rep';

-- 12
SELECT lastName, firstName
FROM employees
WHERE jobTitle = 'Sales Rep' AND officeCode = '1'

-- 13
SELECT lastName, firstName
FROM employees
WHERE jobTitle = 'Sales Rep' OR officeCode = '1'
ORDER BY officeCode ASC, jobTitle ASC;

-- 14
SELECT lastName, firstName
FROM employees
WHERE officeCode BETWEEN 1 AND 3
ORDER BY officeCode ASC;

-- 15
SELECT lastName, firstName
FROM employees
WHERE lastName LIKE '%son'
ORDER BY lastName ASC;

-- 16
SELECT lastName, firstName
FROM employees
WHERE officeCode IN ('1', '2', '3')
ORDER BY officeCode ASC;

-- 17
SELECT lastName, firstName
FROM employees
WHERE reportsTo IS NULL;

-- 18
SELECT lastName, firstName
FROM employees
WHERE jobTitle != 'Sales Rep';

-- 19
SELECT lastName, firstName
FROM employees
WHERE officeCode > '5';

-- 20
SELECT lastName, firstName
FROM employees
WHERE officeCode <= '4'

-- 21
SELECT DISTINCT lastName
FROM employees;

-- 22
SELECT DISTINCT country
FROM customers

-- 23
SELECT DISTINCT city, country
FROM customers
ORDER BY country ASC, city ASC;
