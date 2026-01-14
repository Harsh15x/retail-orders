-- Creation of table df_orders
CREATE TABLE df_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    quantity INT,
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);


--1. find top 10 highest reveue generating products 
select product_id, sum(sale_price)
from df_orders
group by product_id 
order by sum(sale_price) desc
limit 10;


--2. find top 5 highest selling products in each region
SELECT *
FROM (
    SELECT
        region,
        product_id,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY SUM(sale_price) DESC
        ) AS rn
    FROM df_orders
    GROUP BY region, product_id
) t
WHERE rn <= 5;


--3. find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
SELECT
    EXTRACT(MONTH FROM order_date) AS order_month,
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2022 
            THEN sale_price 
            ELSE 0 
        END) AS sales_2022,
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2023 
            THEN sale_price 
            ELSE 0 
        END) AS sales_2023
FROM df_orders
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY order_month;


--4. for each category which month had highest sales 
SELECT
    category,
    order_year_month,
    sales
FROM (
    SELECT
        category,
        TO_CHAR(order_date, 'YYYYMM') AS order_year_month,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY SUM(sale_price) DESC
        ) AS rn
    FROM df_orders
    GROUP BY category, TO_CHAR(order_date, 'YYYYMM')
) t
WHERE rn = 1;



--5. which sub category had highest growth by profit in 2023 compare to 2022
SELECT
    sub_category,
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2022 
            THEN sale_price 
            ELSE 0 
        END) AS sales_2022,
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2023 
            THEN sale_price 
            ELSE 0 
        END) AS sales_2023,
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2023 
            THEN sale_price 
            ELSE 0 
        END)
    -
    SUM(CASE 
            WHEN EXTRACT(YEAR FROM order_date) = 2022 
            THEN sale_price 
            ELSE 0 
        END) AS growth
FROM df_orders
GROUP BY sub_category
ORDER BY growth DESC
LIMIT 1;
