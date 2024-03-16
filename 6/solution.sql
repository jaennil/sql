-- 1.3
DELIMITER $$

CREATE FUNCTION ship_days(
	orderDate DATE,
	requiredDate DATE
)
RETURNS INT
DETERMINISTIC

BEGIN

	RETURN DATEDIFF(orderDate, requiredDate);

END $$

DELIMITER ;

SELECT orders.*, ship_days(requiredDate, orderDate) ship_days FROM orders\G

-- 2.1
CREATE TABLE employees_audit (
id INT AUTO_INCREMENT PRIMARY KEY,
employeeNumber INT NOT NULL,
lastname VARCHAR(50) NOT NULL,
changedat DATETIME DEFAULT NULL,
action VARCHAR(50) DEFAULT NULL
);

CREATE TRIGGER before_employee_update
BEFORE UPDATE ON employees
FOR EACH ROW
INSERT INTO employees_audit
SET action = 'update',
employeeNumber = OLD.employeeNumber,
lastname = OLD.lastname,
changedat = NOW();

UPDATE employees
SET
lastName = 'Phan'
WHERE
employeeNumber = 1056;

SELECT *
FROM employees_audit;

-- 2.2
CREATE TABLE price_logs (
id INT AUTO_INCREMENT,
productCode VARCHAR(15) NOT NULL,
price DECIMAL(10, 2) NOT NULL,
updated_at TIMESTAMP NOT NULL
DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (id),
FOREIGN KEY (productCode)
REFERENCES products (productCode)
ON DELETE CASCADE
ON UPDATE CASCADE
);

DELIMITER $$
CREATE TRIGGER before_products_update
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
IF OLD.msrp <> NEW.msrp THEN
INSERT INTO price_logs(productCode, price)
VALUES(OLD.productCode, OLD.msrp);
END IF;
END$$
DELIMITER ;

SELECT msrp
FROM products
WHERE productCode = 'S12_1099';

UPDATE products
SET msrp = 200
WHERE productCode = 'S12_1099';

CREATE TABLE user_change_logs (
id INT AUTO_INCREMENT,
productCode VARCHAR(15) DEFAULT NULL,
updatedAt TIMESTAMP NOT NULL
DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP,
updatedBy VARCHAR(30) NOT NULL,
PRIMARY KEY (id),
FOREIGN KEY (productCode)
REFERENCES products (productCode)
ON DELETE CASCADE
ON UPDATE CASCADE
);

DELIMITER $$
CREATE TRIGGER before_products_update_log_user
BEFORE UPDATE ON products
FOR EACH ROW
FOLLOWS before_products_update
BEGIN
IF OLD.msrp <> NEW.msrp THEN
INSERT INTO
user_change_logs(productCode, updatedBy)
VALUES
(OLD.productCode, USER());
END IF;
END$$
DELIMITER ;

UPDATE products
SET msrp = 201
WHERE productCode = 'S12_1099';

SELECT *
FROM price_logs;

SELECT *
FROM user_change_logs;

-- 2.3
CREATE TABLE billings (
billingNo INT AUTO_INCREMENT,
customerNo INT,
billingDate DATE,
amount DEC(10, 2),
PRIMARY KEY (billingNo)
);

DELIMITER $$
CREATE TRIGGER before_billing_update
BEFORE UPDATE
ON billings FOR EACH ROW
BEGIN
IF NEW.amount > OLD.amount*10 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'New amount cannot be 10 times greater than the current amount.';
END IF;
END$$
DELIMITER ;

INSERT INTO billings(customerNo, billingDate, amount) VALUES(103, CURDATE(), 10);

UPDATE billings SET amount = amount * 11 WHERE billingNo = 1;

DELIMITER $$

CREATE TRIGGER check_payment_amount
BEFORE INSERT ON payments
FOR EACH ROW
BEGIN
    IF NEW.amount < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'payment amount cant be negative';
    END IF;
END $$

DELIMITER ;

INSERT INTO payments(customerNumber, checkNumber, paymentDate, amount) VALUES(103, 1234, CURDATE(), -1234);

-- 2.4
CREATE TABLE work_centers (
id INT AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(100) NOT NULL,
capacity INT NOT NULL
);

CREATE TABLE work_center_stats(
totalCapacity INT NOT NULL
);

DELIMITER $$
CREATE TRIGGER before_workcenters_insert
BEFORE INSERT
ON work_centers FOR EACH ROW

BEGIN
DECLARE rowcount INT;
SELECT COUNT(*)
INTO rowcount
FROM work_center_stats;
IF rowcount > 0 THEN
UPDATE work_center_stats
SET totalCapacity = totalCapacity + NEW.capacity;
ELSE
INSERT INTO work_center_stats(totalCapacity)
VALUES(NEW.capacity);
END IF;
END $$
DELIMITER ;

INSERT INTO work_centers(name, capacity) VALUES ("testname", 1234);

SELECT *
FROM work_center_stats;

DELIMITER $$

CREATE TRIGGER block_russian_customers
BEFORE INSERT
ON customers FOR EACH ROW
BEGIN

    IF NEW.country = 'Russia' THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'customers from Russia are not allowed';
    END IF;

END $$

DELIMITER ;

INSERT INTO customers(
	customerName, country
)
VALUES(
	'Nikita',
	'Russia'
);

-- 2.5
CREATE TABLE members (
id INT AUTO_INCREMENT,
name VARCHAR(100) NOT NULL,
email VARCHAR(255),
birthDate DATE,
PRIMARY KEY (id)
);

CREATE TABLE reminders (
id INT AUTO_INCREMENT,
memberId INT,
message VARCHAR(255) NOT NULL,
PRIMARY KEY (id, memberId)
);

DELIMITER $$
CREATE TRIGGER after_members_insert
AFTER INSERT
ON members FOR EACH ROW
BEGIN
IF NEW.birthDate IS NULL THEN
INSERT INTO reminders(memberId, message)
VALUES(NEW.id,CONCAT('Hi ', NEW.name, ', please
update your date of birth.'));

END IF;
END$$
DELIMITER ;

INSERT INTO members (name, email)
VALUES ('Nikita', 'nikita@dubrovskih.ru');

SELECT *
FROM reminders;

DELIMITER $$

CREATE TRIGGER after_insert_order
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN

    DECLARE ordered_products INT;

    SELECT SUM(quantityOrdered) INTO ordered_products
    FROM orderdetails
    WHERE orderNumber = NEW.orderNumber;

    IF ordered_products > 50 THEN
        UPDATE orders
        SET comments = 'Large order'
        WHERE orderNumber = NEW.orderNumber;
    END IF;

END $$

DELIMITER ;

INSERT INTO orderdetails(
	orderNumber,
	productCode,
	quantityOrdered,
	priceEach,
	orderLineNumber
)
VALUES(
	10222,
	-- need to change
	'S32_4289',
	51,
	1234,
	1234
);

SELECT comments
FROM orders
WHERE orderNumber = 10222;

-- 2.6
DROP TABLE sales;

CREATE TABLE sales (
id INT AUTO_INCREMENT,
product VARCHAR(100) NOT NULL,
quantity INT NOT NULL DEFAULT 0,
fiscalYear SMALLINT NOT NULL,
fiscalMonth TINYINT NOT NULL,
CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
CHECK(fiscalYear BETWEEN 2000 and 2050),
CHECK (quantity >=0),
UNIQUE(product, fiscalYear, fiscalMonth),
PRIMARY KEY(id)
);

INSERT INTO sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
('2003 Harley-Davidson Eagle Drag Bike', 120, 2020, 1),
('1969 Corvair Monza', 150, 2020, 1),
('1970 Plymouth Hemi Cuda', 200, 2020, 1);

DELIMITER $$
CREATE TRIGGER before_sales_update
BEFORE UPDATE
ON sales FOR EACH ROW
BEGIN
DECLARE errorMessage VARCHAR(255);
SET errorMessage = CONCAT('The new quantity ',
NEW.quantity, ' cannot be 3 times greater than the current
quantity ', OLD.quantity);
IF new.quantity > OLD.quantity*3 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = errorMessage;
END IF;
END $$

DELIMITER ;

UPDATE sales
SET quantity = (quantity * 4)
WHERE product LIKE '2003%';

DELIMITER $$

CREATE TRIGGER before_employee_email_update
BEFORE UPDATE
ON employees FOR EACH ROW
BEGIN
    IF NEW.email LIKE "%yandex.ru" THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Russian emails forbidden';
    END IF;
END $$

DELIMITER ;

UPDATE employees SET email = 'aoeu@yandex.ru' WHERE employeeNumber = 1002;

-- 2.7
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
id INT AUTO_INCREMENT,
product VARCHAR(100) NOT NULL,
quantity INT NOT NULL DEFAULT 0,
fiscalYear SMALLINT NOT NULL,
fiscalMonth TINYINT NOT NULL,
CHECK(fiscalMonth >= 1 AND fiscalMonth <= 12),
CHECK(fiscalYear BETWEEN 2000 and 2050),
CHECK (quantity >=0),
UNIQUE(product, fiscalYear, fiscalMonth),
PRIMARY KEY(id)
);

CREATE TABLE sales_changes (
id INT AUTO_INCREMENT PRIMARY KEY,
salesId INT,
beforeQuantity INT,
afterQuantity INT,
changedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO sales(product, quantity, fiscalYear, fiscalMonth)
VALUES
('2001 Ferrari Enzo', 140, 2021, 1),
('1998 Chrysler Plymouth Prowler', 110, 2021, 1),
('1913 Ford Model T Speedster', 120, 2021, 1);

DELIMITER $$
CREATE TRIGGER after_sales_update
AFTER UPDATE
ON sales FOR EACH ROW
BEGIN
IF OLD.quantity <> NEW.quantity THEN
INSERT INTO sales_changes(salesId, beforeQuantity,
afterQuantity)
VALUES(OLD.id, OLD.quantity, NEW.quantity);
END IF;
END$$
DELIMITER ;

UPDATE sales
SET quantity = quantity * 2
WHERE product LIKE '2001%';

SELECT *
FROM sales_changes;

CREATE TABLE email_history(
	id INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
	employeeNumber INT NOT NULL REFERENCES employees(employeeNumber),
	email VARCHAR(255) NOT NULL,
	date_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

CREATE TRIGGER after_employee_email_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
	INSERT INTO email_history(employeeNumber, email)
	VALUES(OLD.employeeNumber, OLD.email);
END $$

DELIMITER ;

UPDATE employees
SET email = 'aoeu@aoeu.aoeu'
WHERE employeeNumber = 1002;

SELECT *
FROM email_history;

-- 2.8
CREATE TABLE salaries(
employeeNumber INT PRIMARY KEY,
validFrom DATE NOT NULL,
amount DEC(12 , 2) NOT NULL DEFAULT 0
);

CREATE TABLE salary_archives (
    id INT PRIMARY KEY AUTO_INCREMENT,
    employeeNumber INT NOT NULL,
    validFrom DATE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
    deletedAt TIMESTAMP DEFAULT NOW(),
    UNIQUE KEY (employeeNumber, validFrom)
);

INSERT INTO salaries(employeeNumber, validFrom, amount)
VALUES
(1002, '2000-01-01', 50000),
(1056, '2000-01-01', 60000),
(1076, '2000-01-01', 70000);

DELIMITER $$

CREATE TRIGGER before_salaries_delete
BEFORE DELETE
ON salaries FOR EACH ROW
BEGIN
INSERT INTO salary_archives(employeeNumber, validFrom,
amount)
VALUES(OLD.employeeNumber, OLD.validFrom, OLD.amount);
END$$

DELIMITER ;

DELETE FROM salaries
WHERE employeeNumber = 1002;

SELECT *
FROM salary_archives;

DELIMITER $$

CREATE TRIGGER before_president_delete
BEFORE DELETE
ON employees FOR EACH ROW
BEGIN

    IF OLD.jobTitle = "President" THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'cant delete company president';
    END IF;

END $$

DELIMITER ;

DELELE FROM employees
WHERE jobTitle = 'President';

-- 2.9
DROP TABLE IF EXISTS salaries;
CREATE TABLE salaries (
employeeNumber INT PRIMARY KEY,
salary DECIMAL(10, 2) NOT NULL DEFAULT 0
);
CREATE TABLE salary_budgets(
total DECIMAL(15, 2) NOT NULL
);

INSERT INTO salaries(employeeNumber, salary)
VALUES
(1002, 5000),
(1056, 7000),
(1076, 8000);

INSERT INTO salary_budgets(total)
SELECT SUM(salary)
FROM salaries;

CREATE TRIGGER after_salaries_delete
AFTER DELETE
ON salaries FOR EACH ROW
UPDATE salary_budgets
SET total = total - OLD.salary;

DELETE FROM salaries
WHERE employeeNumber = 1002;

SELECT *
FROM salary_budgets;

CREATE TABLE fired_employees
LIKE employees;

DELIMITER $$

CREATE TRIGGER after_employees_delete
AFTER DELETE
ON employees FOR EACH ROW
BEGIN
    INSERT INTO fired_employees (employeeNumber, lastName, firstName, extension, email, officeCode, reportsTo, jobTitle)
    VALUES (OLD.employeeNumber, OLD.lastName, OLD.firstName, OLD.extension, OLD.email, OLD.officeCode, OLD.reportsTo, OLD.jobTitle);
END $$

DELIMITER ;

DELETE FROM employees WHERE employeeNumber = 1076; -- need to change number

SELECT *
FROM fired_employees;
