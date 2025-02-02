-- ============================================================
-- Pizza Sales SQL Project
-- This script contains all queries for the Dominos (Pizza Sales)
-- project, including database/table creation and analysis queries.
-- ============================================================

-- ============================================================
-- 1. Create Database and Tables
-- ============================================================

-- Create the database and use it
CREATE DATABASE dominos;
USE dominos;

-- Create the 'orders' table
CREATE TABLE orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY(order_id)
);

-- Create the 'order_details' table
CREATE TABLE order_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY(order_details_id)
);

-- ============================================================
-- 2. Analysis Queries
-- ============================================================

-----------------------------------------------------
-- Query 1: Retrieve the total number of orders placed.
-----------------------------------------------------
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-------------------------------------------------------
-- Query 2: Calculate the total revenue generated from pizza sales.
-------------------------------------------------------
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
FROM
    order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;

-------------------------------------------------------------
-- Query 3: Identify the highest-priced pizza.
-------------------------------------------------------------
SELECT 
    pizza_types.name, pizzas.price AS highest_price
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-------------------------------------------------------------------
-- Query 4: Identify the most common pizza size ordered.
-------------------------------------------------------------------
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

---------------------------------------------------------------------- 
-- Query 5: List the top 5 most ordered pizza types along with their quantities.
----------------------------------------------------------------------
SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

--------------------------------------------------------------------------
-- Query 6: Join the necessary tables to find the total quantity of each pizza category ordered.
--------------------------------------------------------------------------
SELECT DISTINCT
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

------------------------------------------------------------------------------------
-- Query 7: Determine the distribution of orders by hour of the day.
------------------------------------------------------------------------------------
SELECT 
    HOUR(order_time) AS hour, 
    COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

------------------------------------------------------------------------------------
-- Query 8: Join relevant tables to find the category-wise distribution of pizzas.
------------------------------------------------------------------------------------
SELECT 
    category,
    COUNT(name) AS count
FROM 
    pizza_types 
GROUP BY category;

----------------------------------------------------------------------------------
-- Query 9: Group the orders by date and calculate the average number of pizzas ordered per day.
----------------------------------------------------------------------------------
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_per_day
FROM
    (SELECT 
         orders.order_date, 
         SUM(order_details.quantity) AS quantity
     FROM
         orders
         JOIN order_details ON orders.order_id = order_details.order_id
     GROUP BY orders.order_date) AS order_quantity;

-----------------------------------------------------------------------------------------
-- Query 10: Determine the top 3 most ordered pizza types based on revenue.
-----------------------------------------------------------------------------------------
SELECT 
    pizza_types.name, 
    ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue 
FROM 
    pizza_types 
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.name 
ORDER BY total_revenue DESC 
LIMIT 3;

-------------------------------------------------------------------------------------------
-- Query 11: Calculate the percentage contribution of each pizza type to total revenue.
-------------------------------------------------------------------------------------------
SELECT 
    pizza_types.category,
    ROUND(
        SUM(pizzas.price * order_details.quantity) /
        (SELECT ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_revenue
         FROM order_details
         JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id) * 100,
        2
    ) AS revenue_percentage
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

---------------------------------------------------------------------------------------------
-- Query 12: Analyze the cumulative revenue generated over time.
---------------------------------------------------------------------------------------------
SELECT 
    order_date, 
    SUM(revenue) OVER (ORDER BY order_date) AS cumulative_revenue 
FROM 
    (SELECT 
         orders.order_date, 
         SUM(order_details.quantity * pizzas.price) AS revenue 
     FROM 
         order_details 
         JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id 
         JOIN orders ON orders.order_id = order_details.order_id 
     GROUP BY orders.order_date) AS sales;

----------------------------------------------------------------------------------------------
-- Query 13: Determine the top 3 most ordered pizza types based on revenue for each pizza category.
----------------------------------------------------------------------------------------------
SELECT 
    category, 
    name, 
    revenue 
FROM
    (SELECT 
         category, 
         name, 
         revenue, 
         RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
     FROM 
         (SELECT 
              pizza_types.category, 
              pizza_types.name,
              SUM(order_details.quantity * pizzas.price) AS revenue
          FROM 
              pizza_types 
              JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
              JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
          GROUP BY pizza_types.category, pizza_types.name
         ) AS A
    ) AS B 
WHERE rn <= 3;
