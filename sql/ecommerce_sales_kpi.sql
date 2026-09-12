-- E-Commerce Sales & KPI Performance Analysis
-- MySQL 8+
-- Portfolio/demo dataset. The CSV is generated for this project.

CREATE DATABASE IF NOT EXISTS ecommerce_kpi;
USE ecommerce_kpi;

DROP TABLE IF EXISTS ecommerce_sales_raw;
CREATE TABLE ecommerce_sales_raw (
    Order_ID VARCHAR(30),
    Order_Date DATE,
    Category VARCHAR(100),
    Product VARCHAR(150),
    Region VARCHAR(50),
    Customer_Segment VARCHAR(50),
    Payment_Method VARCHAR(50),
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Discount DECIMAL(5,2),
    Sales DECIMAL(14,2),
    Cost DECIMAL(14,2),
    Profit DECIMAL(14,2)
);

-- Load ecommerce_sales_raw.csv using LOAD DATA LOCAL INFILE in MySQL Workbench.
-- Then run the checks below.

-- 1. Row count
SELECT COUNT(*) AS raw_rows FROM ecommerce_sales_raw;

-- 2. Duplicate orders
SELECT Order_ID, COUNT(*) AS duplicate_count
FROM ecommerce_sales_raw
GROUP BY Order_ID
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

-- 3. Missing-value profile
SELECT
 SUM(Order_ID IS NULL OR Order_ID='') AS missing_order_id,
 SUM(Order_Date IS NULL) AS missing_date,
 SUM(Category IS NULL OR Category='') AS missing_category,
 SUM(Product IS NULL OR Product='') AS missing_product,
 SUM(Region IS NULL OR Region='') AS missing_region,
 SUM(Customer_Segment IS NULL OR Customer_Segment='') AS missing_segment,
 SUM(Payment_Method IS NULL OR Payment_Method='') AS missing_payment,
 SUM(Quantity IS NULL) AS missing_quantity,
 SUM(Unit_Price IS NULL) AS missing_unit_price,
 SUM(Discount IS NULL) AS missing_discount,
 SUM(Sales IS NULL) AS missing_sales
FROM ecommerce_sales_raw;

-- 4. Clean duplicate orders with ROW_NUMBER
DROP TABLE IF EXISTS ecommerce_sales_clean;
CREATE TABLE ecommerce_sales_clean AS
SELECT *
FROM (
    SELECT e.*,
           ROW_NUMBER() OVER(PARTITION BY Order_ID ORDER BY Order_Date) AS rn
    FROM ecommerce_sales_raw e
) x
WHERE rn=1;

ALTER TABLE ecommerce_sales_clean DROP COLUMN rn;

-- 5. Handle missing dimensions and numeric values
UPDATE ecommerce_sales_clean SET Region='Unknown'
WHERE Region IS NULL OR TRIM(Region)='';

UPDATE ecommerce_sales_clean SET Payment_Method='Unknown'
WHERE Payment_Method IS NULL OR TRIM(Payment_Method)='';

UPDATE ecommerce_sales_clean SET Category='Unknown'
WHERE Category IS NULL OR TRIM(Category)='';

UPDATE ecommerce_sales_clean
SET Quantity=1
WHERE Quantity IS NULL OR Quantity<1;

-- 6. KPI summary
SELECT
 COUNT(*) AS orders,
 SUM(Quantity) AS units_sold,
 ROUND(SUM(Sales),2) AS revenue,
 ROUND(SUM(Profit),2) AS profit,
 ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin_pct,
 ROUND(AVG(Sales),2) AS avg_order_value
FROM ecommerce_sales_clean;

-- 7. Category performance
SELECT Category,
       COUNT(*) AS orders,
       SUM(Quantity) AS units_sold,
       ROUND(SUM(Sales),2) AS revenue,
       ROUND(SUM(Profit),2) AS profit,
       ROUND(SUM(Profit)/NULLIF(SUM(Sales),0)*100,2) AS margin_pct
FROM ecommerce_sales_clean
GROUP BY Category
ORDER BY revenue DESC;

-- 8. Region performance
SELECT Region, COUNT(*) AS orders,
       ROUND(SUM(Sales),2) AS revenue,
       ROUND(SUM(Profit),2) AS profit
FROM ecommerce_sales_clean
GROUP BY Region
ORDER BY revenue DESC;

-- 9. Monthly trend
SELECT YEAR(Order_Date) AS year,
       MONTH(Order_Date) AS month,
       DATE_FORMAT(Order_Date,'%b') AS month_name,
       ROUND(SUM(Sales),2) AS revenue,
       ROUND(SUM(Profit),2) AS profit
FROM ecommerce_sales_clean
GROUP BY YEAR(Order_Date), MONTH(Order_Date), DATE_FORMAT(Order_Date,'%b')
ORDER BY year, month;

-- 10. Customer segment
SELECT Customer_Segment,
       COUNT(*) AS orders,
       ROUND(SUM(Sales),2) AS revenue,
       ROUND(AVG(Sales),2) AS avg_order_value
FROM ecommerce_sales_clean
GROUP BY Customer_Segment
ORDER BY revenue DESC;

-- 11. Top 10 products
SELECT Product, Category,
       SUM(Quantity) AS units_sold,
       ROUND(SUM(Sales),2) AS revenue
FROM ecommerce_sales_clean
GROUP BY Product, Category
ORDER BY revenue DESC
LIMIT 10;

-- 12. Revenue contribution by category
WITH category_sales AS (
    SELECT Category, SUM(Sales) revenue
    FROM ecommerce_sales_clean
    GROUP BY Category
),
total_sales AS (
    SELECT SUM(revenue) total_revenue FROM category_sales
)
SELECT c.Category,
       ROUND(c.revenue,2) AS revenue,
       ROUND(c.revenue/t.total_revenue*100,2) AS revenue_contribution_pct
FROM category_sales c CROSS JOIN total_sales t
ORDER BY revenue DESC;
