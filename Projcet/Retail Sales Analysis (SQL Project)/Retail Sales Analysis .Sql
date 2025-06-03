-- Database Setup 
CREATE DATABASE sales;
CREATE TABLE retail_sales (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID VARCHAR(10),
    CustomerName VARCHAR(100),
    ProductID VARCHAR(10),
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    TotalPrice DECIMAL(10,2),
    StoreID VARCHAR(10),
    StoreLocation VARCHAR(100)
);


-- 2. Data Cleaning & Exploration
-- Total Records:

SELECT COUNT(*) FROM retail_sales;


​
-- Unique Customers:

SELECT COUNT(DISTINCT CustomerID) FROM retail_sales;


​
-- Product Categories:

SELECT DISTINCT Category FROM retail_sales;

-- Check & Remove Nulls:

SELECT * FROM retail_sales
WHERE OrderID IS NULL OR OrderDate IS NULL OR Category IS NULL;

DELETE FROM retail_sales
WHERE OrderID IS NULL OR OrderDate IS NULL OR Category IS NULL;


-- Business Questions & SQL Queries
-- 1. Sales on a Specific Date

SELECT * FROM retail_sales WHERE OrderDate = '2023-03-10';

-- 2. Top 5 Categories by Sales

SELECT Category, SUM(TotalPrice) AS TotalSales
FROM retail_sales
GROUP BY Category
ORDER BY TotalSales DESC
LIMIT 5;

-- 3. High-Value Transactions (>500)

SELECT * FROM retail_sales WHERE TotalPrice > 500;
​
-- 4. Sales by Store

SELECT StoreLocation, COUNT(OrderID), SUM(TotalPrice)
FROM retail_sales
GROUP BY StoreLocation;

-- 5. Monthly Sales Trend

SELECT DATE_FORMAT(OrderDate, '%Y-%m') AS Month, SUM(TotalPrice)
FROM retail_sales
GROUP BY Month
ORDER BY Month;

-- 6. Quantity Sold per Category

SELECT Category, SUM(Quantity) FROM retail_sales GROUP BY Category;
​
-- 7. Top 5 Best-Selling Products

SELECT ProductName, SUM(Quantity)
FROM retail_sales
GROUP BY ProductName
ORDER BY SUM(Quantity) DESC
LIMIT 5;
​
-- 8. Top 5 Customers

SELECT CustomerName, SUM(TotalPrice)
FROM retail_sales
GROUP BY CustomerName
ORDER BY SUM(TotalPrice) DESC
LIMIT 5;


-- 9. Shift-wise Order Count

SELECT
  CASE
    WHEN HOUR(OrderDate) < 12 THEN 'Morning'
    WHEN HOUR(OrderDate) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS Shift,
  COUNT(*) AS Orders
FROM retail_sales
GROUP BY Shift;

-- 10. Unique Buyers per Category

SELECT Category, COUNT(DISTINCT CustomerID)
FROM retail_sales
GROUP BY Category;


-- Some SQL Questions Beginner to Intermediate 
--1.How many orders were placed in each shift per store?
-- (Combines shift logic with location grouping)
SELECT
  StoreLocation,
  CASE
    WHEN HOUR(OrderDate) < 12 THEN 'Morning'
    WHEN HOUR(OrderDate) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS Shift,
  COUNT(*) AS OrderCount
FROM retail_sales
GROUP BY StoreLocation, Shift;

​
-- 2.Find the top 3 highest total price orders per month

SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY MONTH(OrderDate) ORDER BY TotalPrice DESC) AS rank
  FROM retail_sales
) AS ranked
WHERE rank <= 3;

-- 3.Find average order value by hour of the day

SELECT
  HOUR(OrderDate) AS Hour,
  ROUND(AVG(TotalPrice), 2) AS AvgOrderValue
FROM retail_sales
GROUP BY HOUR(OrderDate)
ORDER BY Hour;

-- 4.How many unique customers placed orders each month?

SELECT
  DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
  COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM retail_sales
GROUP BY Month;

-- 5.List all rows with missing values in any column

SELECT * FROM retail_sales
WHERE OrderID IS NULL
   OR OrderDate IS NULL
   OR CustomerID IS NULL
   OR Category IS NULL
   OR ProductName IS NULL;


​
-- 6.Find the percentage contribution of each product to total category sales

SELECT
  Category,
  ProductName,
  ROUND(SUM(TotalPrice) * 100.0 / SUM(SUM(TotalPrice)) OVER (PARTITION BY Category), 2) AS ProductSalesPercent
FROM retail_sales
GROUP BY Category, ProductName
ORDER BY Category, ProductSalesPercent DESC;


​
-- 7.Compare average sale value between weekdays and weekends

SELECT
  CASE
    WHEN DAYOFWEEK(OrderDate) IN (1,7) THEN 'Weekend'
    ELSE 'Weekday'
  END AS DayType,
  ROUND(AVG(TotalPrice), 2) AS AvgSale
FROM retail_sales
GROUP BY DayType;
​
-- 8.Find the days with no sales activity at all

-- First, generate a calendar (if needed in SQL engine)
-- Assume a table named calendar_dates exists with one date per row
SELECT DATE(OrderDate) AS SaleDate, COUNT(*) AS Orders
FROM retail_sales
GROUP BY SaleDate
HAVING Orders = 0;
​
-- 9.Find customers who ordered in more than 3 different months

SELECT CustomerID, CustomerName, COUNT(DISTINCT DATE_FORMAT(OrderDate, '%Y-%m')) AS ActiveMonths
FROM retail_sales
GROUP BY CustomerID, CustomerName
HAVING ActiveMonths > 3;
​
-- 10.Calculate cumulative monthly sales over time

SELECT
  DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
  SUM(TotalPrice) AS MonthlySales,
  SUM(SUM(TotalPrice)) OVER (ORDER BY DATE_FORMAT(OrderDate, '%Y-%m')) AS CumulativeSales
FROM retail_sales
GROUP BY Month;
