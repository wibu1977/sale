# Analyze sales performance over time
# Track sales , gross sales, discounts 
SELECT `Gross Sales`, `Sales`, `Discounts`
FROM customer_sale;

# Identify sales by product,segment,country
SELECT SUM(sales) AS total_sale, Product, Segment, Country
FROM customer_sale
GROUP BY Product, Segment, Country
ORDER BY total_sale DESC
LIMIT 10;  
#Top 10 customers who using products the most
SELECT Segment, Country,
	   SUM(CASE WHEN Year = 2014 THEN Sales ELSE 0 END) AS Sales_2014,
       SUM(CASE WHEN Year = 2013 THEN Sales ELSE 0 END) AS Sales_2013,
       CONCAT(
           FORMAT(
               ((SUM(CASE WHEN Year = 2014 THEN Sales ELSE 0 END) - SUM(CASE WHEN Year = 2013 THEN Sales ELSE 0 END)) / SUM(CASE WHEN Year = 2013 THEN Sales ELSE 0 END)) * 100,
               2
           ),
           '%'
       ) AS Sales_Growth
FROM customer_sale
WHERE YEAR IN ( 2013,2014)
GROUP BY Segment, Country
LIMIT 10;


# Profitability of each segments

SELECT Segment,
       SUM(CASE WHEN Year = 2013 THEN Profit ELSE 0 END) AS Profit_2013,
       SUM(CASE WHEN Year = 2014 THEN Profit ELSE 0 END) AS Profit_2014
FROM customer_sale
WHERE Year IN (2013, 2014)
GROUP BY Segment
ORDER BY Segment DESC
LIMIT 10;
# Profitability of each products
SELECT Product,
       SUM(CASE WHEN Year = 2013 THEN Profit ELSE 0 END) AS Profit_2013,
       SUM(CASE WHEN Year = 2014 THEN Profit ELSE 0 END) AS Profit_2014
FROM customer_sale
WHERE Year IN (2013, 2014)
GROUP BY Product
ORDER BY Product DESC
LIMIT 10;

# Analyze the impact of discounts on proftability
SELECT 
  *,
  Discounts/`Gross Sales` AS Discount_Percent
FROM customer_sale;
SELECT
  CASE 
    WHEN Discounts/`Gross Sales` < 0.05 THEN '0-5%'
    WHEN Discounts/`Gross Sales`< 0.10 THEN '5-10%'
    WHEN Discounts/`Gross Sales` < 0.15 THEN '10-15%'
    WHEN Discounts/`Gross Sales` < 0.20 THEN '15-20%'
    ELSE '20%+' 
  END AS Discount_Bracket,
  
  SUM(`Gross Sales`) AS Total_Sales,
  SUM(Discounts) AS Total_Discounts,
  SUM(Profit) AS Total_Profit,
  
  AVG(Discounts/`Gross Sales`) AS Avg_Discount_Percent
  
FROM customer_sale
GROUP BY Discount_Bracket
ORDER BY Avg_Discount_Percent;


# Track price for different products and Segments over time
SELECT Product, Segment,
    CASE WHEN Year = 2013 THEN `Sale Price` END AS Price_2013,
    CASE WHEN Year = 2014 THEN `Sale Price` END AS Price_2014
FROM customer_sale;


# Caculate price elasticity for products and segment

SELECT 
  t1.Segment,
  t1.Product,
  t1.`Sale Price` AS Current_Price,
  t1.`Units Sold` AS Current_Qty,
  t2.`Sale Price` AS Previous_Price, 
  t2.`Units Sold` AS Previous_Qty
FROM customer_sale t1 
JOIN customer_sale t2 
ON t1.Product = t2.Product 
AND t1.Segment = t2.Segment
WHERE t1.Year = 2014 AND t2.Year = 2013;

SELECT
  Segment,
  Product,
  Current_Price,
  Current_Qty,
  Previous_Price,
  Previous_Qty,
  ((Current_Price - Previous_Price)/Previous_Price) AS Price_Change_Pct,
  ((Current_Qty - Previous_Qty)/Previous_Qty) AS Qty_Change_Pct
FROM
(SELECT 
  t1.Segment,
  t1.Product,
  t1.`Sale Price` AS Current_Price,
  t1.`Units Sold` AS Current_Qty,
  t2.`Sale Price` AS Previous_Price, 
  t2.`Units Sold` AS Previous_Qty
FROM customer_sale t1 
JOIN customer_sale t2 
ON t1.Product = t2.Product 
AND t1.Segment = t2.Segment
WHERE t1.Year = 2014 AND t2.Year = 2013
) AS elasticity_data;

SELECT 
  Segment,
  Product,
  Price_Change_Pct,
  Qty_Change_Pct,
  (Qty_Change_Pct/Price_Change_Pct) AS Price_Elasticity
FROM 
(
  SELECT
    Segment,
    Product,
    Current_Price,
    Current_Qty,
    Previous_Price,
    Previous_Qty,
    ((Current_Price - Previous_Price)/Previous_Price) AS Price_Change_Pct,
    ((Current_Qty - Previous_Qty)/Previous_Qty) AS Qty_Change_Pct
  FROM
  (
    SELECT 
      t1.Segment,
      t1.Product,
      t1.`Sale Price` AS Current_Price,
      t1.`Units Sold` AS Current_Qty,
      t2.`Sale Price` AS Previous_Price, 
      t2.`Units Sold` AS Previous_Qty
    FROM customer_sale t1 
    JOIN customer_sale t2 
    ON t1.Product = t2.Product 
    AND t1.Segment = t2.Segment
    WHERE t1.Year = 2014 AND t2.Year = 2013
  ) AS elasticity_data
) AS outer_subquery;

# Find cross-selling opportunityacross segments

SELECT
  Segment,
  Product,
  SUM(`Gross Sales`) AS Total_Sales,
  (SUM(`Gross Sales`)/MAX(Segment_Total_Sales)) AS Product_Share
FROM
  (SELECT 
    Segment,
    Product,
    `Gross Sales`,
    SUM(`Gross Sales`) OVER (PARTITION BY Segment) AS Segment_Total_Sales
   FROM customer_sale) sale_data
GROUP BY Segment, Product;


SELECT 
  Segment,
  Product,
  Product_Share,
  CASE WHEN Product_Share > 0.2 THEN 'Higher Share' ELSE 'Lower Share' END AS Share_Category
FROM 
  (SELECT
  Segment,
  Product,
  SUM(`Gross Sales`) AS Total_Sales,
  (SUM(`Gross Sales`)/MAX(Segment_Total_Sales)) AS Product_Share
FROM
  (SELECT 
    Segment,
    Product,
    `Gross Sales`,
    SUM(`Gross Sales`) OVER (PARTITION BY Segment) AS Segment_Total_Sales
   FROM customer_sale) sale_data
GROUP BY Segment, Product) AS prod_share;










