-- 1.1
UPDATE employees
SET email = 'mary.patterso@classicmodelcars.com'
WHERE lastName = 'Patterson' AND firstname = 'Mary';

SELECT email
FROM employees
WHERE lastName = 'Patterson' AND firstname = 'Mary';

-- 1.2
UPDATE employees
SET lastName = 'Hill', email = 'mary.hill@classicmodelcars.com'
WHERE employeeNumber = 1056;

SELECT *
FROM employees
WHERE employeeNumber = 1056;

-- 1.3
UPDATE employees
SET email = REPLACE(email, '@classicmodelcars.com', '@mysqltutorial.org')
WHERE jobTitle = 'Sales Rep' AND officeCode = 6;

SELECT *
FROM employees
WHERE jobTitle = 'Sales Rep' AND officeCode = 6;

-- 1.4
UPDATE customers
SET salesRepEmployeeNumber = (
	SELECT employeeNumber
	FROM employees
	ORDER BY RAND()
	LIMIT 1
)
WHERE salesRepEmployeeNumber IS NULL;

SELECT *
FROM customers
WHERE salesRepEmployeeNumber IS NULL;

-- 1.5
START TRANSACTION;

DELETE FROM customers
WHERE country = 'France'
ORDER BY RAND()
LIMIT 5;

ROLLBACK;

SELECT *
FROM customers
WHERE country = 'France'

-- 1.6
START TRANSACTION;

DELETE FROM customers
WHERE customerNumber NOT IN (
	SELECT customerNumber
	FROM orders
);

ROLLBACK;

SELECT *
FROM customers
WHERE customerNumber NOT IN (
	SELECT customerNumber
	FROM orders
);

-- 1.7
ALTER TABLE customers
DROP FOREIGN KEY customers_ibfk_1;

ALTER TABLE employees
DROP FOREIGN KEY employees_ibfk_2;

ALTER TABLE employees
DROP FOREIGN KEY employees_ibfk_1;

ALTER TABLE employees
ADD CONSTRAINT fk_officeCode
FOREIGN KEY (officeCode)
REFERENCES offices(officeCode)
ON DELETE CASCADE;

START TRANSACTION;

DELETE FROM offices
WHERE officeCode = 4;

SELECT *
FROM offices
WHERE officeCode = 4;

ROLLBACK;

SELECT *
FROM offices
WHERE officeCode = 4;

ALTER TABLE customers
ADD CONSTRAINT customers_ibfk_1
FOREIGN KEY (salesRepEmployeeNumber)
REFERENCES employees(employeeNumber);

ALTER TABLE employees
ADD CONSTRAINT employees_ibfk_1
FOREIGN KEY (reportsTo)
REFERENCES employees (employeeNumber);

-- 1.8
START TRANSACTION;

SELECT
	@orderNumber := MAX(orderNUmber) + 1
FROM
	orders;

INSERT INTO orders(
	orderNumber,
	orderDate,
	requiredDate,
	shippedDate,
	status,
	customerNumber)
VALUES(
	@orderNumber,
	'2005-05-31',
	'2005-06-10',
	'2005-06-11',
	'In Process',
	145);

INSERT INTO orderdetails(
	orderNumber,
	productCode,
	quantityOrdered,
	priceEach,
	orderLineNumber)
VALUES(
	@orderNumber,'S18_1749', 30, '136', 1),
	(@orderNumber,'S18_2248', 50, '55.09', 2);

COMMIT;

SELECT *
FROM orders
ORDER BY orderNumber DESC
LIMIT 1;

SELECT *
FROM orderdetails
ORDER BY orderNumber DESC
LIMIT 1;

-- 2.1
DELIMITER $$

CREATE PROCEDURE GetCustomers()
BEGIN

	SELECT *
	FROM customers;

END $$

DELIMITER ;

-- 2.6
DELIMITER $$
CREATE PROCEDURE GetCustomerLevel(
IN pCustomerNumber INT,
OUT pCustomerLevel VARCHAR(20))
BEGIN
DECLARE credit DECIMAL(10,2) DEFAULT 0;
SELECT creditLimit
INTO credit
FROM customers
WHERE customerNumber = pCustomerNumber;
IF credit > 50000 THEN
SET pCustomerLevel = 'PLATINUM';
END IF;
END$$

SELECT *
FROM customers
WHERE creditLimit > 50000
ORDER BY creditLimit;

-- 2.7
DELIMITER $$
CREATE PROCEDURE GetCustomerLevel(
IN pCustomerNumber INT,
OUT pCustomerLevel VARCHAR(20))
BEGIN
DECLARE credit DECIMAL DEFAULT 0;
SELECT creditLimit
INTO credit
FROM customers
WHERE customerNumber = pCustomerNumber;
IF credit > 50000 THEN
SET pCustomerLevel = 'PLATINUM';
ELSE
SET pCustomerLevel = 'NOT PLATINUM';
END IF;
END$$
DELIMITER ;

SELECT *
FROM customers
WHERE creditLimit <= 50000
ORDER BY creditLimit;

-- 2.12
DELIMITER $$
CREATE PROCEDURE CheckCredit(
inCustomerNumber int
)
sp: BEGIN
DECLARE customerCount INT;
SELECT
COUNT(*)
INTO customerCount
FROM
customers
WHERE
customerNumber = inCustomerNumber;
IF customerCount = 0 THEN
LEAVE sp;
END IF;
END$$
DELIMITER ;

CALL CheckCredit(141);

-- 2.15
DELIMITER $$
CREATE PROCEDURE AddOrderItem(
in orderNo int,
in productCode varchar(45),
in qty int,
in price double,
in lineNo int )
BEGIN
DECLARE C INT;
SELECT COUNT(orderNumber) INTO C
FROM orders
WHERE orderNumber = orderNo;
IF(C != 1) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Order No not found in orders table';
END IF;
END$$
DELIMITER ;

CALL AddOrderItem(-1, -1, -1, -1, -1);

