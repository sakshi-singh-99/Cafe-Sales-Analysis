SELECT * FROM dbo.café_sales;

SELECT 
    COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'café_sales';


-- 4. Alter `transaction_time` column to TIME data type

ALTER TABLE café_sales
ALTER COLUMN transaction_time TIME;


-- 5. Check data types of all columns
EXEC sp_help 'café_sales';


-- 7. Total Sales for May

SELECT ROUND(SUM(unit_price * transaction_qty),0) AS Total_Sales
FROM café_sales
WHERE MONTH(transaction_date) = 5;


-- 8. Total Sales KPI – MoM Growth

WITH monthly_sales AS (
SELECT MONTH(transaction_date) AS month,
SUM(unit_price * transaction_qty) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
)
SELECT month,
ROUND(total_sales,0) AS total_sales,
ROUND((total_sales - LAG(total_sales) OVER(ORDER BY month))*100.0/
LAG(total_sales) OVER(ORDER BY month),2) AS mom_growth
FROM monthly_sales;


-- 9. Total Orders for May

SELECT COUNT(transaction_id) AS Total_Orders
FROM café_sales
WHERE MONTH(transaction_date)=5;


-- 10. Total Orders KPI – MoM Growth

WITH monthly_orders AS (
SELECT MONTH(transaction_date) AS month,
COUNT(transaction_id) AS total_orders
FROM café_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
)
SELECT month,total_orders,
ROUND((total_orders-LAG(total_orders) OVER(ORDER BY month))*100.0/
LAG(total_orders) OVER(ORDER BY month),2) AS mom_growth
FROM monthly_orders;


-- 11. Total Quantity Sold in May

SELECT SUM(transaction_qty) AS Total_Quantity_Sold
FROM café_sales
WHERE MONTH(transaction_date)=5;



-- 12. Total Quantity KPI – MoM Growth

WITH monthly_qty AS (
SELECT MONTH(transaction_date) AS month,
SUM(transaction_qty) AS total_qty
FROM café_sales
WHERE MONTH(transaction_date) IN (4,5)
GROUP BY MONTH(transaction_date)
)
SELECT month,total_qty,
ROUND((total_qty-LAG(total_qty) OVER(ORDER BY month))*100.0/
LAG(total_qty) OVER(ORDER BY month),2) AS mom_growth
FROM monthly_qty;



-- 13. Daily Sales, Quantity, Orders for specific date

SELECT SUM(unit_price*transaction_qty) AS total_sales,
SUM(transaction_qty) AS total_quantity,
COUNT(transaction_id) AS total_orders
FROM café_sales
WHERE transaction_date='2023-05-18';



-- 14. Average Daily Sales for May

SELECT AVG(daily_sales) AS avg_sales
FROM (
SELECT SUM(unit_price*transaction_qty) AS daily_sales
FROM café_sales
WHERE MONTH(transaction_date)=5
GROUP BY transaction_date
) a;



-- 15. Daily Sales for May

SELECT DAY(transaction_date) AS day,
ROUND(SUM(unit_price*transaction_qty),1) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date)=5
GROUP BY DAY(transaction_date)
ORDER BY day;



-- 16. Compare Daily Sales with Average

WITH ds AS (
    SELECT 
        DAY(transaction_date) AS d,
        SUM(unit_price * transaction_qty) AS ts
    FROM café_sales
    WHERE MONTH(transaction_date) = 5
    GROUP BY DAY(transaction_date)
)

SELECT 
    d AS Day,
    CASE 
        WHEN ts > AVG(ts) OVER() THEN 'Above Average'
        WHEN ts < AVG(ts) OVER() THEN 'Below Average'
        ELSE 'Average'
    END AS status,
    ts AS [Total Sales]
FROM ds;



-- 17. Sales by Weekday vs Weekend

SELECT CASE WHEN DATEPART(WEEKDAY,transaction_date) IN (1,7)
THEN 'Weekends' ELSE 'Weekdays' END AS day_type,
SUM(unit_price*transaction_qty) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date)=5
GROUP BY CASE WHEN DATEPART(WEEKDAY,transaction_date) IN (1,7)
THEN 'Weekends' ELSE 'Weekdays' END;



-- 18. Sales by Store Location

SELECT 
    CAST(store_location AS NVARCHAR(100)) AS store_location,
    SUM(unit_price * transaction_qty) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date) = 5
GROUP BY CAST(store_location AS NVARCHAR(100))
ORDER BY total_sales DESC;



-- 19. Sales by Product Category

SELECT 
    product_category_converted AS product_category,
    Total_Sales
FROM (
    SELECT 
        CAST(product_category AS NVARCHAR(200)) AS product_category_converted,
        ROUND(SUM(CAST(unit_price AS DECIMAL(10,2)) * CAST(transaction_qty AS INT)), 1) AS Total_Sales
    FROM dbo.café_sales
    WHERE DATEPART(MONTH, transaction_date) = 5
    GROUP BY CAST(product_category AS NVARCHAR(200))
) AS sub
ORDER BY Total_Sales DESC;


-- 20. Top 10 Products by Sales

SELECT TOP 10 
    CAST(product_type AS NVARCHAR(200)) AS product_type,
    SUM(CAST(unit_price AS DECIMAL(10,2)) * CAST(transaction_qty AS INT)) AS total_sales
FROM dbo.café_sales
WHERE DATEPART(MONTH, transaction_date) = 5
GROUP BY CAST(product_type AS NVARCHAR(200))
ORDER BY total_sales DESC;



-- 21. Sales by Specific Day and Hour

SELECT SUM(unit_price*transaction_qty) AS total_sales,
SUM(transaction_qty) AS total_qty,
COUNT(*) AS total_orders
FROM café_sales
WHERE DATEPART(WEEKDAY,transaction_date)=3
AND DATEPART(HOUR,transaction_time)=8
AND MONTH(transaction_date)=5;



-- 22. Sales from Monday to Sunday

SELECT DATENAME(WEEKDAY,transaction_date) AS day,
SUM(unit_price*transaction_qty) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date)=5
GROUP BY DATENAME(WEEKDAY,transaction_date);



-- 23. Sales for All Hours

SELECT DATEPART(HOUR,transaction_time) AS hour,
SUM(unit_price*transaction_qty) AS total_sales
FROM café_sales
WHERE MONTH(transaction_date)=5
GROUP BY DATEPART(HOUR,transaction_time)
ORDER BY hour;