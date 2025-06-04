-- 1. Create Database
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- 2. Drop tables if exist (to reset)
DROP TABLE IF EXISTS return_status;
DROP TABLE IF EXISTS issued_status;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS branch;

-- 3. Create Tables

CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn)
);

CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

-- 4. Insert Sample Data (some sample records)

-- Insert branches
INSERT INTO branch VALUES 
('B001', 'E101', '123 Main St', '555-1234'),
('B002', 'E102', '456 Park Ave', '555-5678');

-- Insert employees
INSERT INTO employees VALUES
('E101', 'Alice Johnson', 'Manager', 75000.00, 'B001'),
('E102', 'Bob Smith', 'Manager', 72000.00, 'B002'),
('E103', 'Carol White', 'Librarian', 45000.00, 'B001'),
('E104', 'David Brown', 'Assistant', 40000.00, 'B002');

-- Insert members
INSERT INTO members VALUES
('M001', 'John Doe', '789 Elm St', '2024-01-10'),
('M002', 'Jane Smith', '234 Oak St', '2024-03-15'),
('M003', 'Mike Johnson', '567 Pine St', '2024-02-05'),
('M004', 'Emily Davis', '890 Maple St', '2024-04-01');

-- Insert books
INSERT INTO books VALUES
('978-0-12345-678-9', 'The Great Gatsby', 'Classic', 5.00, 'yes', 'F. Scott Fitzgerald', 'Scribner'),
('978-1-23456-789-0', '1984', 'Dystopian', 4.50, 'yes', 'George Orwell', 'Secker & Warburg'),
('978-1-34567-890-1', 'The Catcher in the Rye', 'Classic', 4.00, 'no', 'J.D. Salinger', 'Little, Brown and Company'),
('978-1-45678-901-2', 'The Hobbit', 'Fantasy', 6.00, 'yes', 'J.R.R. Tolkien', 'George Allen & Unwin'),
('978-1-56789-012-3', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Insert issued_status
INSERT INTO issued_status VALUES
('IS120', 'M001', 'The Great Gatsby', '2024-05-01', '978-0-12345-678-9', 'E103'),
('IS121', 'M002', '1984', '2024-05-05', '978-1-23456-789-0', 'E104'),
('IS122', 'M001', 'The Hobbit', '2024-05-07', '978-1-45678-901-2', 'E103'),
('IS123', 'M003', 'To Kill a Mockingbird', '2024-05-10', '978-1-56789-012-3', 'E104');

-- Insert return_status
INSERT INTO return_status VALUES
('RS100', 'IS120', 'The Great Gatsby', '2024-05-15', '978-0-12345-678-9');

-- 5. CRUD Operation Queries

-- Task 1: Create a New Book Record
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher) 
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '999 New Address St'
WHERE member_id = 'M002';

-- Task 3: Delete a Record from issued_status table
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee (emp_id = 'E101')
SELECT issued_book_name, issued_date
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
SELECT issued_member_id, COUNT(*) AS books_issued_count
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;

-- 6. CTAS: Create a summary table with each book and total issued count
CREATE TABLE book_issue_summary AS
SELECT issued_book_isbn, COUNT(*) AS total_issued
FROM issued_status
GROUP BY issued_book_isbn;

-- 7. Retrieve All Books in a Specific Category (e.g., 'Classic')
SELECT * FROM books WHERE category = 'Classic';

-- 8. Find Total Rental Income by Category
SELECT b.category, SUM(b.rental_price) AS total_rental_income
FROM books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY b.category;

-- 9. List Members Who Registered in the Last 180 Days
SELECT * FROM members
WHERE reg_date >= DATE_SUB(CURDATE(), INTERVAL 180 DAY);

-- 10. List Employees with Their Branch Manager's Name and Branch Details
SELECT e.emp_id, e.emp_name, e.position, b.manager_id, b.branch_address, b.contact_no
FROM employees e
JOIN branch b ON e.branch_id = b.branch_id;

-- 11. Create a Table of Books with Rental Price Above a Certain Threshold (e.g., 5.00)
CREATE TABLE expensive_books AS
SELECT * FROM books WHERE rental_price > 5.00;

-- 12. Retrieve the List of Books Not Yet Returned
SELECT i.issued_id, i.issued_member_id, i.issued_book_name, i.issued_date
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.issued_id IS NULL;

-- 13. Identify Members with Overdue Books (over 30 days)
SELECT m.member_id, m.member_name, b.book_title, i.issued_date,
       DATEDIFF(CURDATE(), i.issued_date) - 30 AS days_overdue
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN books b ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.issued_id IS NULL
AND DATEDIFF(CURDATE(), i.issued_date) > 30;

-- 14. Update Book Status to "Yes" When Returned
UPDATE books b
SET status = 'yes'
WHERE isbn IN (
    SELECT return_book_isbn FROM return_status
);

-- 15. Branch Performance Report
SELECT br.branch_id, br.branch_address,
       COUNT(DISTINCT i.issued_id) AS books_issued,
       COUNT(DISTINCT r.return_id) AS books_returned,
       SUM(b.rental_price) AS total_revenue
FROM branch br
LEFT JOIN employees e ON br.branch_id = e.branch_id
LEFT JOIN issued_status i ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
LEFT JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY br.branch_id, br.branch_address;

-- 16. CTAS: Create a Table of Active Members (issued a book in last 2 months)
CREATE TABLE active_members AS
SELECT DISTINCT m.member_id, m.member_name, m.member_address, m.reg_date
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
WHERE i.issued_date >= DATE_SUB(CURDATE(), INTERVAL 2 MONTH);

-- 17. Find Top 3 Employees with Most Book Issues Processed
SELECT e.emp_name, COUNT(i.issued_id) AS books_processed, e.branch_id
FROM employees e
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY e.emp_id, e.emp_name, e.branch_id
ORDER BY books_processed DESC
LIMIT 3;

-- 18. Identify Members Issuing More Than Twice "damaged" Books
SELECT m.member_name, b.book_title, COUNT(*) AS times_issued_damaged
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN books b ON i.issued_book_isbn = b.isbn
WHERE b.status = 'damaged'
GROUP BY m.member_name, b.book_title
HAVING COUNT(*) > 2;

-- 19. Stored Procedure to manage book issuance and status update

DELIMITER //
CREATE PROCEDURE issue_book (IN input_isbn VARCHAR(50))
BEGIN
    DECLARE current_status VARCHAR(10);
    SELECT status INTO current_status FROM books WHERE isbn = input_isbn;
    
    IF current_status = 'yes' THEN
        UPDATE books SET status = 'no' WHERE isbn = input_isbn;
        SELECT CONCAT('Book with ISBN ', input_isbn, ' has been issued.') AS message;
    ELSE
        SELECT CONCAT('Error: Book with ISBN ', input_isbn, ' is currently not available.') AS message;
    END IF;
END;
//
DELIMITER ;

-- To call the stored procedure:
-- CALL issue_book('978-0-12345-678-9');

-- 20. CTAS to identify overdue books and calculate fines
CREATE TABLE overdue_fines AS
SELECT i.issued_id, m.member_id, m.member_name, b.book_title, i.issued_date,
       DATEDIFF(CURDATE(), i.issued_date) - 30 AS days_overdue,
       CASE 
         WHEN DATEDIFF(CURDATE(), i.issued_date) > 30 
         THEN (DATEDIFF(CURDATE(), i.issued_date) - 30) * b.rental_price * 0.1
         ELSE 0
       END AS fine_amount
FROM issued_status i
JOIN members m ON i.issued_member_id = m.member_id
JOIN books b ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.issued_id IS NULL
AND DATEDIFF(CURDATE(), i.issued_date) > 30;
