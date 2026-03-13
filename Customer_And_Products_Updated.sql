CREATE DATABASE CustomersAndProduct;
SHOW DATABASES;
USE CustomersAndProduct;

SELECT * FROM cleaned_superstore;


  -- 1. Total sales by customer segment
SELECT 
    Segment,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM cleaned_superstore
GROUP BY Segment
ORDER BY Total_Sales DESC;

-- KEY INSIGHTS:
-- The top segment gives the most sales.
-- Focus more on this segment to grow business.
-- Segments with less sales need attention.

-- 2. Average discount applied per region
SELECT 
    Region,
    ROUND(AVG(Discount), 4) AS Average_Discount
FROM cleaned_superstore
GROUP BY Region
ORDER BY Average_Discount DESC;

-- KEY INSIGHTS: 
-- hows the average discount given in each region.
-- Helps find regions where more discounts are applied.
-- Useful to check if high discounts are affecting profit in certain regions.

  -- 3. total sales and categorize customers based on their total discount as 'High Discount',
  -- 'Medium Discount', or 'Low Discount'. 
SELECT 
    `Customer Name`,
    Region,
    ROUND(SUM(Sales), 0) AS Total_Sales,
    CASE
        WHEN AVG(Discount) >= 0.20 THEN 'High Discount'
        WHEN AVG(Discount) BETWEEN 0.10 AND 0.199 THEN 'Medium Discount'
        ELSE 'Low Discount'
    END AS Discount_Level
FROM cleaned_superstore
GROUP BY `Customer Name`, Region
ORDER BY Total_Sales DESC
LIMIT 10;

-- INSIGHTS: 
-- Top customers bring high sales from specific regions.
-- Most top customers get Low or Medium discounts.
-- Giving High discounts doesn't always mean more sales.

  -- 4. products based on profit margin as 'High Profit', 'Moderate Profit', or 'Low/Negative Profit'. 
  -- Return product name, category, sub-category, total sales, total profit, and profit category.
SELECT 
    `Product Name`,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(Profit), 3) AS Total_Profit,
    CASE
        WHEN SUM(Profit) / NULLIF(SUM(Sales), 0) >= 0.20 THEN 'High Profit'
        WHEN SUM(Profit) / NULLIF(SUM(Sales), 0) BETWEEN 0.05 AND 0.199 THEN 'Moderate Profit'
        ELSE 'Low/Negative Profit'
    END AS Profit_Category
FROM cleaned_superstore
GROUP BY `Product Name`, Category, `Sub-Category`
ORDER BY Total_Sales DESC
LIMIT 20;
 
 -- INSIGHTS: 
-- Some high-selling products still have low profit margins.
-- High profit products are not always the top in sales.
-- Category and sub-category affect profit levels a lot.

  -- Q5. Each product into 'Best Seller', 'Moderate Seller', or 'Low Seller' based on its total sales.
SELECT 
    `Product Name`,
    Category,
    `Sub-Category`,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    CASE
        WHEN SUM(Sales) > 10000 THEN 'Best Selling'
        WHEN SUM(Sales) BETWEEN 1000 AND 3000 THEN 'Moderate Selling'
        ELSE 'Low Selling'
    END AS Sales_Status
FROM cleaned_superstore
GROUP BY `Product Name`, Category, `Sub-Category`
ORDER BY Total_Sales DESC;

-- INSIGHTS: 
-- Best-selling products have sales above ₹10,000.
-- Most top products fall in the Best Selling group.
-- Moderate and low sellers may need better promotion or review.

  -- 6. Top-Selling by Revenue
SELECT 
    `Product Name`,
    Category,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM cleaned_superstore
GROUP BY `Product Name`, Category
ORDER BY Total_Sales DESC
LIMIT 10;

-- Shows the top 10 products with highest sales revenue.
-- These products are the main revenue drivers for the business.
-- Ideal for focus in promotions, stocking, and strategy.

  -- 7. Low-selling Products 
SELECT 
    `Product Name`,
    Category,
    SUM(Sales) AS Total_Sales
FROM cleaned_superstore
GROUP BY `Product Name`, Category
HAVING SUM(Sales) < 500
ORDER BY Total_Sales ASC
LIMIT 10;

-- KEY INSIGHTS: 
-- Lists products with very low total sales (below ₹500).
-- These products may be less popular or poorly marketed.
-- Useful for deciding whether to improve, discount, or remove such products.

  -- 8. Product Sales by Region 
SELECT 
    `Product Name`,
    Category,
    Region,
    ROUND(SUM(Sales), 2) AS Total_Sales
FROM cleaned_superstore
GROUP BY Region, `Product Name`, Category
ORDER BY Total_Sales DESC
LIMIT 100;

-- KEY INSIGHTS: 
-- Shows which products sell most in each region.
-- Helps identify regional demand and preferences.
-- Useful for region-wise marketing and inventory planning.

  -- 9. Best Product Per Category (Max Sales) 
SELECT Category, `Product Name`, Total_Sales
FROM (
    SELECT Category, `Product Name`, SUM(Sales) AS Total_Sales,
           RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS rnk
    FROM cleaned_superstore
    GROUP BY Category, `Product Name`
) AS ranked_products
WHERE rnk = 1
ORDER BY Category; 

-- KEY INSIGHTS: 
-- Shows the best-selling product in each category.
-- These products are the top contributors to sales within their category.
-- They are ideal for promotion and restocking to boost revenue.

  -- 10. Now using CTE, Best Product Per Category (Max Sales) 
-- Step 1: Calculate total sales for each product in each category
WITH ProductSales AS (  -- This is the first CTE
    SELECT Category, `Product Name`, SUM(Sales) AS Total_Sales FROM cleaned_superstore
    GROUP BY Category, `Product Name`
),
-- Step 2: Find maximum sales per category
MaxSalesPerCategory AS (  -- This is the second CTE
    SELECT Category, MAX(Total_Sales) AS Max_Sales FROM ProductSales
    GROUP BY Category
)
-- Step 3: Get the product(s) that have the highest sales in their category
SELECT ps.Category,ps.`Product Name`, ps.Total_Sales FROM ProductSales ps
JOIN MaxSalesPerCategory ms
     ON ps.Category = ms.Category
     AND ps.Total_Sales = ms.Max_Sales
ORDER BY ps.Category;

-- KEY INSIGHTS: 
-- These are the top-selling products in each category.
-- They bring the highest sales within their category.
-- These products are key for revenue, so they should be promoted more.

  -- 11. top 2 selling products in terms of total sales per category. 
-- Step 1: Calculate total sales for each product in each category
WITH ProductSales AS (  -- First CTE: total sales per product
    SELECT Category, `Product Name`, ROUND(SUM(Sales), 2) AS Total_Sales FROM cleaned_superstore
    GROUP BY Category, `Product Name`
),
-- Step 2: Rank products by total sales within each category
RankedProducts AS (  -- Second CTE: assign ranks per category
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY Category ORDER BY Total_Sales DESC) AS Sales_Rank
    FROM ProductSales
)
-- Step 3: Select top 2 products per category
SELECT Category, `Product Name`, Total_Sales FROM RankedProducts
WHERE Sales_Rank <= 2
ORDER BY Category, Sales_Rank;


-- KEY INSIGHTS: 
-- These are the top 2 best-selling products in each category.
-- They play a big role in category-wise revenue.
-- These products can be focused for promotions and stocking.
  
  -- 12. Find all products where average discount is high (=> 20%) but total profit is low (≤ 100).
-- Step 1: Calculate average discount and total profit for each product
WITH ProductsAnalysis AS (  -- CTE: analyze discount and profit per product
    SELECT `Product Name`, Category,
           ROUND(AVG(Discount), 2) AS Avg_Discount,
           SUM(Profit) AS Total_Profit
    FROM cleaned_superstore
    GROUP BY `Product Name`, Category
)
-- Step 2: Select products with high discount (>=20%) and low profit (<=100)
SELECT *FROM ProductsAnalysis
WHERE Avg_Discount >= 0.20
  AND Total_Profit <= 100
ORDER BY Avg_Discount DESC;
    
-- KEY INSIGHTS: 
-- These products get a high discount (20% or more).
-- Even after discounts, they give very low profit (₹100 or less).
-- Such products may be hurting profit and need pricing or discount review.

  -- 13. Month-over-mont sales growth per category
-- Step 1: Calculate total sales per category for each month
WITH MonthlySales AS (  -- First CTE: monthly sales per category
    SELECT Category, DATE_FORMAT(`Order Date`, '%Y-%m') AS Order_Month,
           ROUND(SUM(Sales), 2) AS Monthly_Sales
    FROM cleaned_superstore
    GROUP BY Category, Order_Month
),
-- Step 2: Get previous month's sales to calculate growth
SalesGrowth AS (  -- Second CTE: add previous month sales for comparison
    SELECT *,
           LAG(Monthly_Sales) OVER (PARTITION BY Category ORDER BY Order_Month) AS Prev_Month_Sales
    FROM MonthlySales
)
-- Step 3: Calculate month-over-month growth percentage
SELECT Category, Order_Month, Monthly_Sales,
       ROUND(((Monthly_Sales - Prev_Month_Sales) / NULLIF(Prev_Month_Sales, 0)) * 100, 2) AS Growth_Percentage
FROM SalesGrowth
WHERE Prev_Month_Sales IS NOT NULL
ORDER BY Category, Order_Month;


-- KEY INSIGHTS: 
-- Shows how sales changed each month for every category.
-- Helps find fast-growing or declining categories.
-- Useful to plan marketing and stock based on monthly trends.

  -- 14. first Product purchased by each customer based on order date. 
WITH CustomerOrders AS (
    SELECT `Customer Name`, `Order Date`, `Product Name`, 
    ROW_NUMBER() OVER (
    PARTITION BY `Customer Name` 
    ORDER BY `Order Date`) AS Order_Rank
    FROM cleaned_superstore
)
SELECT `Customer Name`, `Order Date`, `Product Name`
FROM CustomerOrders
WHERE Order_Rank = 1
ORDER BY `Customer Name`;

-- KEY INSIGHT: 
-- It shows the first product each customer bought.
-- Useful to understand what attracts new customers.
-- These products can be used for starter offers or promotions. 

  -- 15. First highest Sales product 
SELECT `Product Name`,
       Category,
       SUM(Sales) AS Total_Sales
FROM cleaned_superstore
GROUP BY `Product Name`, Category
ORDER BY Total_Sales DESC
LIMIT 1;

-- KEY INSIGHTS:
-- This gives the highest selling product overall.
-- It shows the product that generates the maximum revenue.
-- This product is the main revenue driver of the business.

  -- 16. Second highest Sales product 
  SELECT `Product Name`,
       Category,
       SUM(Sales) AS Total_Sales
FROM cleaned_superstore
GROUP BY `Product Name`, Category
ORDER BY Total_Sales DESC
LIMIT 1 OFFSET 1;
  
-- KEY INSIGHTS: 
-- This gives the second highest selling product overall.
-- It shows which product is just below the top in performance.
-- This product has strong sales potential and can be promoted more to reach the top spot.


