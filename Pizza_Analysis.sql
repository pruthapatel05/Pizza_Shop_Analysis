create database if not exists pizza;

use pizza;
CREATE TABLE IF NOT EXISTS orders (
    order_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL,
    PRIMARY KEY (order_id)
);


CREATE TABLE IF NOT EXISTS orders_details (
    order_details_id INT NOT NULL,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    quantity INT NOT NULL,
    PRIMARY KEY (order_details_id)
);


-- Retrive the total number of order placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.

SELECT 
    SUM(pizza_order_details.quantity * pizzas.price) AS total_sales
FROM
    pizza_order_details
        JOIN
    pizzas ON pizza_order_details.pizza_id = pizzas.pizza_id;
    
    
    
-- Calculate the highest-priced pizza
use pizza;
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;




-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;


-- List the top most 5 ordered pizza types along with their quantity
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- Total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    COUNT(pizza_order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizzas.pizza_id = pizza_order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- Determine the distribution of orders by hour of the day 

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);


-- Find the category-wise distribution of the pizzas.
SELECT 
    pizza_types.category, COUNT(pizza_types.name)
FROM
    pizza_types
GROUP BY pizza_types.category;


-- Group the orders by date and calculate the average number of pizzas ordered per day
SELECT 
    AVG(quantity) AS avg_pizzas_order_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(pizza_order_details.quantity) AS quantity
    FROM
        orders
    JOIN pizza_order_details ON orders.order_id = pizza_order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    
-- Determine the top 3 most pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * pizza_order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizzas.pizza_id = pizza_order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(pizza_order_details.quantity * pizzas.price) / (SELECT 
                    SUM(pizza_order_details.quantity * pizzas.price) AS total_sales
                FROM
                    pizza_order_details
                        JOIN
                    pizzas ON pizza_order_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    pizza_order_details ON pizzas.pizza_id = pizza_order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- analyze the cumulative revenue generated over time.

select 
	order_date, sum(revenue) over(order by order_date) as cum_revenue from
(select
	orders.order_date, sum(pizza_order_details.quantity * pizzas.price) as revenue 
    from orders 
    join pizza_order_details
	on orders.order_id = pizza_order_details.order_id 
    join pizzas
	on pizzas.pizza_id = pizza_order_details.pizza_id 
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select category,name, revenue 
from
(select 
	category, name, revenue, rank() 
    over(partition by category order by revenue desc) as rn 
    from
	(select pizza_types.category, pizza_types.name, sum(pizza_order_details.quantity * pizzas.price) as revenue
	from pizza_types 
    join pizzas
	on pizza_types.pizza_type_id = pizzas.pizza_type_id 
    join pizza_order_details
	on pizza_order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b 
where rn<=3;