-- 1
SELECT customerName
FROM customers
WHERE state = 'CA' AND country = 'USA';

-- 2
SELECT customerName, state, creditLimit
FROM customers
WHERE state = 'CA' AND creditLimit >= 100000;

-- 3
SELECT customerName, country
FROM customers
WHERE country = 'USA' OR country = 'France';

-- 4
SELECT customerName, country, creditLimit
FROM customers
WHERE (country = 'USA' OR country = 'France') AND creditLimit >= 100000;

-- 5
SELECT officeCode, country
FROM offices
WHERE country IN ('USA', 'France');

-- 6
SELECT productName, buyPrice
FROM products
WHERE buyPrice BETWEEN 90 AND 100;

-- 7
SELECT productName, buyPrice
FROM products
WHERE buyPrice NOT BETWEEN 20 AND 100;

-- 8
SELECT orderNumber, orderDate
FROM orders
WHERE orderDate BETWEEN CAST('2003-01-01' AS DATE) AND CAST('2003-01-31' AS DATE);

-- 9
SELECT *
FROM employees
WHERE firstname LIKE 'a%';

-- 10
SELECT *
FROM employees
WHERE lastName LIKE '%on';

-- 11
SELECT *
FROM employees
WHERE lastName LIKE '%on%';

-- 12
SELECT *
FROM employees
WHERE firstName LIKE 'T_m';

-- 13
SELECT *
FROM employees
WHERE lastName NOT LIKE 'B%';

-- 14
SELECT *
FROM products
WHERE productCode LIKE '%\_20%';

-- 15
SELECT *
FROM customers
ORDER BY creditLimit DESC
LIMIT 5;

-- 16
SELECT customerNumber
FROM customers
ORDER BY creditLimit ASC
LIMIT 5;

-- 17
SELECT customerName
FROM customers
ORDER BY customerName
LIMIT 10;

-- 18
SELECT customerName
FROM customers
ORDER BY customerName
LIMIT 10, 10;

-- 19
SELECT customerName
FROM customers
ORDER BY creditLimit
LIMIT 1, 1;

-- 20
SELECT DISTINCT *
FROM customers
LIMIT 5;

-- 21
SELECT customerName
FROM customers
WHERE salesRepEmployeeNumber IS NULL
ORDER BY customerName;

-- 22
SELECT customerName
FROM customers
WHERE salesRepEmployeeNumber IS NOT NULL
ORDER BY customerName;

-- 23
CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT,
    title VARCHAR(255),
    begin_date DATE NOT NULL,
    complete_date DATE NOT NULL,
    PRIMARY KEY(id)
);

SET sql_mode = '';

INSERT INTO projects(title, begin_date, complete_date)
VALUES ('New CRM', '2020-01-01', '0000-00-00'),
       ('ERP Future', '2020-01-01', '0000-00-00'),
       ('VR', '2020-01-01', '2030-01-01');

SELECT *
FROM projects
WHERE complete_date = CAST('0000-00-00' AS DATE);

-- 24
SET @@sql_auto_is_null = 1;

INSERT INTO projects(title, begin_date, complete_date)
VALUES ('MRP III', '2010-01-01', '2020-12-31');

SELECT id
FROM projects;

