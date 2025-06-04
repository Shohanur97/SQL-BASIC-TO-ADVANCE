
## 📚 Project Overview

**Project Title:** Library Management System (SQL)
**Level:** Intermediate
**Database:** `library_db`

This project simulates a comprehensive Library Management System implemented entirely using SQL. It covers all essential aspects of relational database management, including schema design, CRUD operations (Create, Read, Update, Delete), advanced SQL queries, stored procedures, and CTAS (Create Table As Select).

Designed to mirror real-world library operations, this system manages branches, employees, members, books, and their issuing and returning activities. It not only supports day-to-day data management but also provides insightful analytics — such as identifying overdue books, generating branch performance reports, and highlighting active members.

This project serves as a practical demonstration of SQL skills applicable for data analysts, database administrators, and backend developers working with relational data systems.



## 🏗️ Project Structure & Database Design

The database `library_db` includes these main tables:

| Table Name      | Purpose                                |
| --------------- | -------------------------------------- |
| `branch`        | Details about each library branch      |
| `employees`     | Staff working at branches              |
| `members`       | Registered library members             |
| `books`         | Catalog of all books with availability |
| `issued_status` | Tracks books issued to members         |
| `return_status` | Tracks returned books                  |

All tables are linked with appropriate **primary keys** and **foreign key constraints** to maintain data integrity.

---

## ⚙️ Setup Instructions

### 1. Create Database & Tables

```sql
CREATE DATABASE library_db;
USE library_db;

/* Branch Table */
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

/* Employees Table */
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

/* Members Table */
CREATE TABLE members (
    member_id VARCHAR(10) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

/* Books Table */
CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

/* Issued Status Table */
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

/* Return Status Table */
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(30),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

### 2. Insert Sample Data

Add realistic sample data into each table to simulate a working library. Sample CSV files are included in the `/data` directory.

---

## 💻 CRUD Operations & Key SQL Queries

### Create

```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-0-32165-723-5', 'The Alchemist', 'Fiction', 5.50, 'yes', 'Paulo Coelho', 'HarperOne');
```

### Read

```sql
SELECT * FROM books WHERE category = 'Fiction';
```

### Update

```sql
UPDATE members
SET member_address = '123 New Street, Springfield'
WHERE member_id = 'M102';
```

### Delete

```sql
DELETE FROM issued_status WHERE issued_id = 'IS121';
```

---

## 🔍 Sample Advanced Queries

* **List members who issued more than one book**

```sql
SELECT issued_member_id, COUNT(*) AS books_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;
```

* **Books not yet returned**

```sql
SELECT i.issued_book_name, i.issued_member_id, i.issued_date
FROM issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL;
```

* **Members with overdue books (30-day policy)**

```sql
SELECT m.member_id, m.member_name, b.book_title, i.issued_date,
       DATEDIFF(CURDATE(), i.issued_date) - 30 AS days_overdue
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
JOIN books b ON i.issued_book_isbn = b.isbn
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL
AND DATEDIFF(CURDATE(), i.issued_date) > 30;
```

* **Top 3 employees by number of book issues**

```sql
SELECT e.emp_name, COUNT(*) AS books_processed, e.branch_id
FROM employees e
JOIN issued_status i ON e.emp_id = i.issued_emp_id
GROUP BY e.emp_id
ORDER BY books_processed DESC
LIMIT 3;
```

---

## 🛠️ Stored Procedure Example

```sql
DELIMITER //

CREATE PROCEDURE IssueBook(IN book_isbn VARCHAR(50))
BEGIN
    DECLARE available VARCHAR(10);

    SELECT status INTO available
    FROM books
    WHERE isbn = book_isbn;

    IF available = 'yes' THEN
        UPDATE books
        SET status = 'no'
        WHERE isbn = book_isbn;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book is currently not available';
    END IF;
END //
```


## 📈 Reports & Analysis

This project includes comprehensive reporting and data analysis capabilities to provide meaningful insights into library operations:

### Database Schema

* Clearly defined tables with primary and foreign keys ensure data integrity and proper relationships among branches, employees, members, books, and transactions.

Here is your content reformatted in clean **GitHub README-style markdown** using bold headings, bullet points, and consistent spacing:

---

### 📊 **Data Analysis Highlights**

* **📚 Book Categories:**
  Analyze popular book categories based on rental frequency and revenue generated.

* **💰 Employee Salaries:**
  Insights into salary distribution across positions and branches to help assess staffing budgets.

* **🧑‍💼 Member Registration Trends:**
  Track new member sign-ups over time to monitor library growth and engagement.

* **📖 Issued Books:**
  Monitor books issued, return frequency, and overdue records to manage inventory and enforce policies.

---

### 📋 **Summary Reports**

* **🔥 High-Demand Books:**
  Identify the most frequently issued books to guide collection management and acquisition planning.

* **🏅 Employee Performance:**
  Rank employees by the number of book issues processed to support performance reviews and incentive programs.

* **🏢 Branch Performance:**
  View aggregated metrics for each branch—including books issued, returned, and revenue earned—to support operational decisions.


## 🎯 Conclusion

This Library Management System project shows how SQL can be used to build and manage a real library database. It covers everything from adding and updating data (CRUD operations) to writing advanced queries and using stored procedures.

Through this project, i learn how to organize data about books, members, employees, and branches — and how to answer important questions like which books are overdue, how many books each branch issues, and which employees handle the most transactions.









