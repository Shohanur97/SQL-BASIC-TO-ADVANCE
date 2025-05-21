CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,  -- Integer type for customer_id, set as primary key
    name VARCHAR(100),            -- Variable character field with a max length of 100 characters
    email VARCHAR(100),           -- Variable character field for email
    city VARCHAR(100)             -- Variable character field for city
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,        -- Integer type for order_id, set as primary key
    customer_id INT,                 -- Integer type for customer_id (this will reference the Customers table)
    order_date DATE,                 -- Date type for order date
    total_amount DECIMAL(10, 2),     -- Decimal type for total order amount (up to 10 digits, with 2 decimal places)
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)  -- Establishing a foreign key relationship
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,      -- Product ID, unique and not null
    product_name VARCHAR(255),       -- Product name with a maximum length of 255 characters
    category VARCHAR(100),           -- Product category (e.g., Electronics, Furniture)
    price DECIMAL(10, 2)             -- Price with 2 decimal points
);


/*Let’s say we have a Products table and an Order_Details table. 
An order can have many products, and each product can appear in many orders. 
This is a many-to-many relationship.*/


CREATE TABLE Order_Details (
    order_id INT,                    -- ID of the order (foreign key)
    product_id INT,                  -- ID of the product (foreign key)
    quantity INT,                    -- Quantity of the product in the order
     PRIMARY KEY (order_id, product_id),-- Composite primary key (unique pair of order_id and product_id)
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),      -- Foreign key from Orders
    FOREIGN KEY (product_id) REFERENCES Products(product_id)  -- Foreign key from Products
);


--1. INNER JOIN:
--Question: List all customer names and their corresponding order total amounts, but only for customers who have placed orders.

select c.name,c.city, o.total_amount from customers c
inner join orders o on c.customer_id = o.customer_id;

/*Why INNER JOIN is used here:
Because we want only customers who have placed orders.
That means:
We only want customers who have a match in the Orders table.
We exclude customers with no orders.*/

--2. LEFT JOIN:
--Question: List all customers and their corresponding order amounts. If a customer has not placed any orders, show NULL for the order amount.

select c.name,o.total_amount from
 customers c 
 Left join orders o
 on c.customer_id = o.customer_id
 where o.order_id is null;


/*Why LEFT JOIN?
You want to list all customers — whether they placed an order or not.
The order amount exists only if a customer placed an order.
For customers with no matching order, we still want their names to appear — and show NULL for the order amount.

 Why This Works:
The LEFT JOIN includes all customers.
If a customer has no matching order, order_amount will be NULL.
So, we filter where order_amount IS NULL.
*/


/* 3. RIGHT JOIN:
Question: List all orders and the corresponding customer names. 
If an order is not associated with a customer, show NULL for the customer name.*/

SELECT o.order_id, c.name
FROM Orders o
RIGHT JOIN Customers c ON o.customer_id = c.customer_id;


/* Why RIGHT JOIN is used here:
This question says:
Include all orders, even if they don’t have a matching customer.
If an order has no customer, show NULL for the customer name.

What does RIGHT JOIN do?
It returns all rows from the right table (Orders), and the matching rows from the left table (Customers).
If there's no matching customer, the customer_name will be NULL.*/


4. FULL OUTER JOIN:
Question: List all customers and orders, 
including customers who haven't placed any orders and orders with no customer.
Show only the rows where either the customer or the order is missing — i.e., only unmatched records (both sides don't match).
*/

SELECT c.name, o.order_id as ID, o.total_amount as amount
FROM Customers c
FULL OUTER JOIN Orders o ON c.customer_id = o.customer_id
WHERE
    c.customer_id IS NULL OR o.customer_id IS NULL;

/* 4 Why Use FULL OUTER JOIN?
A FULL OUTER JOIN combines the results of:
LEFT JOIN (all customers, even if no orders)
RIGHT JOIN (all orders, even if no customer)
This ensures that:
All customers are included (even if they never ordered).
All orders are included (even if there's no matching customer, e.g., due to bad/missing customer_id).

What We Need:
From a FULL OUTER JOIN, we want only the unmatched rows — that means:
Customers who have no orders (order_id IS NULL)
Orders that have no matching customer (customer_id IS NULL from customers) */


/*5. CROSS JOIN:
Question: List every customer with every product, showing all possible combinations of customers and products.

✅ Why Use CROSS JOIN?
A CROSS JOIN returns the Cartesian product of two tables:
Every row from the first table is combined with every row from the second table.
It’s used when you want all possible combinations between two sets.

🧠 In This Case:
You want to pair:
Every customer (from customers table)
With every product (from products table)
Regardless of whether a customer has purchased a product or not.

*/

select c.name,p.product_name,p.category 
from customers c
cross join products p 


/* 
6. INNER JOIN with 3 Tables:
Question: Show order details including the customer name, product name, and quantity ordered.

✅ Why Use INNER JOIN Here?
You're combining data from three related tables:
Orders – contains customer_id, product_id, quantity
Customers – to get the customer name
Products – to get the product name

Since you only want matching data (i.e., valid orders with valid customer and product references), you use INNER JOIN to:

Include only rows where the foreign keys (customer_id, product_id) have matches in their respective tables

Avoid showing incomplete or orphaned data

*/

select c.customer_id,c.name,product_name,p.price,od.quantity
from customers c
inner join orders o on c.customer_id = o.customer_id
INNER JOIN Order_Details od ON o.order_id = od.order_id
INNER JOIN Products p ON od.product_id = p.product_id

order by quantity limit 50;



/*7. LEFT JOIN + NULL Filter:
Question: Find customers who have not placed any orders.
✅ Question:
Find customers who have not placed any orders.

*/

SELECT c.name,o.order_date
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;



/*8. RIGHT JOIN + NULL Filter:
Question: Find orders that don't have any associated customer information (showing only orders with NULL customer names).

✅ Question:
Find orders that don't have any associated customer information (i.e., orders where customer info is missing).

🧠 Why Use RIGHT JOIN + NULL Filter?
🎯 Goal:
You want to find orders that exist in the Orders table, but the customer info is missing — possibly due to:
Data entry errors
Deleted or corrupted customer records
Foreign key mismatch

*/

SELECT o.order_id, c.name
FROM Orders o
RIGHT JOIN Customers c ON o.customer_id = c.customer_id
WHERE c.name IS NULL;


/*
9. FULL OUTER JOIN with Aggregation:
Question: Show the total sales per product, including products that have not been sold.
*/

SELECT p.product_name, SUM(od.quantity) AS total_sales
FROM Products p
FULL OUTER JOIN Order_Details od ON p.product_id = od.product_id
GROUP BY p.product_name;


/*
10. CROSS JOIN with Filtering:
Question: List every customer and every product they could potentially buy (with a filter, e.g., only "Electronics" products).

*/

SELECT c.name, p.product_name
FROM Customers c
CROSS JOIN Products p
WHERE p.category = 'Electronics';


