---

# **Amazon USA Sales Analysis Project**

### **Difficulty Level: Advanced**

---

## **Project Overview**

I have worked on analyzing a dataset of over 20,000 sales records from an Amazon-like e-commerce platform. This project involves extensive querying of customer behavior, product performance, and sales trends using PostgreSQL. Through this project, I have tackled various SQL problems, including revenue analysis, customer segmentation, and inventory management.

The project also focuses on data cleaning, handling null values, and solving real-world business problems using structured queries.

An ERD diagram is included to visually represent the database schema and relationships between tables.

---

![ERD Scratch](https://github.com/najirh/amazon_usa_project5/blob/main/erd2.png)

## **Database Setup & Design**

### **Schema Structure**

```sql
-- creating parent/fact tables
-- category table
create table category(
category_id int primary key,	
category_name varchar(20) not null
);

-- customers table
create table customers(
customer_id int primary key,
first_name varchar(15),
last_name varchar(15),
state varchar(20)
);

--sellers table
create table sellers(
seller_id int primary key,	
seller_name	varchar(25),
origin varchar(10)
);

-- creating child/Dimension tables
--prodduct table
create table products(
product_id int primary key,	
product_name varchar(50),	
price float,	
cogs float,	
category_id int,
constraint product_fk_categoy foreign key(category_id) references category(category_id)
);

-- orders table
create table orders(
order_id int primary key,	
order_date date,	
customer_id	int,
seller_id int,
order_status varchar(15),
constraint orders_fk_customers foreign key(customer_id) references customers(customer_id),
constraint orders_fk_sellers foreign key(seller_id) references sellers(seller_id)
);

-- order_items table
create table order_items(
order_item_id int primary key,
order_id int,	
product_id int,	
quantity int,	
price_per_unit float,
constraint order_items_fk_orders foreign key(order_id) references orders(order_id),
constraint order_items_fk_products foreign key(product_id) references products(product_id)
);

-- inventory table
create table inventory(
inventory_id int primary key,	
product_id int,	
stock int,	
warehouse_id int,	
last_stock_date date,
constraint inventory_fk_products foreign key(product_id) references products(product_id)
);

-- payments table
create table payments(
payment_id int primary key,	
order_id int,	
payment_date date,	
payment_status varchar(20),
constraint payments_fk_orders foreign key(order_id) references orders(order_id)
);

-- shipping table
create table shipping(
shipping_id	int primary key,
order_id int,	
shipping_date date,	
return_date	date,
shipping_providers varchar(15),	
delivery_status varchar(15),
constraint shipping_fk_orders foreign key(order_id) references orders(order_id)
);

--importing data to these tables
copy category 
(category_id, category_name)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\category.csv'
DELIMITER ','
CSV HEADER;

copy customers 
(customer_id, first_name, last_name, state)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\customers.csv'
DELIMITER ','
CSV HEADER;

copy sellers 
(seller_id, seller_name, origin)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\sellers.csv'
DELIMITER ','
CSV HEADER;

copy products 
(product_id, product_name, price, cogs, category_id)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\products.csv'
DELIMITER ','
CSV HEADER;

copy orders 
(order_id, order_date, customer_id, seller_id, order_status)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\orders.csv'
DELIMITER ','
CSV HEADER;

copy order_items 
(order_item_id, order_id, product_id, quantity, price_per_unit)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\order_items.csv'
DELIMITER ','
CSV HEADER;

copy inventory 
(inventory_id, product_id, stock, warehouse_id, last_stock_date)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\inventory.csv'
DELIMITER ','
CSV HEADER;

copy shipping 
(shipping_id, order_id, shipping_date, return_date, shipping_providers, delivery_status)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\shipping.csv'
DELIMITER ','
CSV HEADER;

copy payments 
(payment_id, order_id, payment_date, payment_status)
FROM 'C:\Program Files\PostgreSQL\P3 Amazon DB Analysis\payments.csv'
DELIMITER ','
CSV HEADER;
```

---

## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---

## **Objective**

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations, including:
- Customer behavior
- Sales trends
- Inventory management
- Payment and shipping analysis
- Forecasting and product performance
  

## **Identifying Business Problems**

Key business problems identified:
1. Low product availability due to inconsistent restocking.
2. High return rates for specific product categories.
3. Significant delays in shipments and inconsistencies in delivery times.
4. High customer acquisition costs with a low customer retention rate.

---

## **Solving Business Problems**

### Solutions Implemented:
1. Top Selling Products
Query the top 10 products by total sales value.
Challenge: Include product name, total quantity sold, and total sales value.

```sql
with t as (
select p.product_id, p.product_name, sum(oi.quantity) as total_quantity, 
round(sum(oi.quantity * oi.price_per_unit)::numeric, 2) as total_sales_value
from order_items as oi
left join products as p
using (product_id)
group by 1, 2)

select * from t
order by total_sales_value desc
limit 10;
```

2. Revenue by Category
Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.

```sql
with g as(
with f as (
select * from category as c
Left join products as p
using (category_id)
Left join order_items as oi
using (product_id)
)
select category_name, 
round(sum(quantity*price_per_unit)::numeric, 2) as revenue
from f
group by category_name)

select *,
round(revenue/(select sum(revenue) from g)*100, 2) as percent_contribution
from g;

```

3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.

```sql
with i as (
with h as(
select *, round(quantity*price_per_unit::numeric, 2) as revenue from customers as c
Left join orders as o
using(customer_id)
Left join order_items
using(order_id))

select customer_id, count(customer_id) as no_of_orders, sum(revenue) as total_spend
from h
group by 1
order by no_of_orders desc)

select *, round(total_spend/no_of_orders, 2) as AOV from i
where no_of_orders > 5;
```

4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale!

```sql
WITH enriched_payments AS (
    SELECT 
        p.*,
        oi.product_id,
        oi.quantity,
        oi.price_per_unit,
        ROUND(oi.quantity * oi.price_per_unit::numeric, 2) AS revenue,
        EXTRACT(YEAR FROM p.payment_date) AS yearly,
        TO_CHAR(p.payment_date, 'FMMonth') AS monthly
    FROM payments AS p
    LEFT JOIN order_items AS oi USING(order_id)
    WHERE p.payment_date >= CURRENT_DATE - INTERVAL '3 year'
)
SELECT 
    yearly, 
    monthly, 
    SUM(revenue) AS total_revenue,
	lag(SUM(revenue)) over (order by yearly, monthly)
FROM enriched_payments
GROUP BY yearly, monthly
ORDER BY yearly, TO_DATE(monthly, 'Month');
```


5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.

```sql
with l as (
with k as (
select customer_id, count(order_id) as no_of_orders
from customers as c
left join orders as o
using (customer_id)
group by 1
order by no_of_orders)

select * from k 
where no_of_orders = 0)

select * from l
left join customers
using (customer_id)
```

6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.

```sql
with n as (
with m as(
select * from products as p
left join category as c
using(category_id)
left join order_items
using (product_id)
left join orders
using(order_id)
left join customers
using(customer_id))

select state, category_name, count(category_name) as counted, round(sum(quantity*price_per_unit)::numeric, 2) as revenue,
rank() over(partition by state order by count(category_name))
from m
group by state, category_name
order by state, count(category_name))

select * from n 
where rank = 1
order by counted desc;
```


7. Customer Lifetime Value (CLTV)
Calculate the total value of orders placed by each customer over their lifetime.
Challenge: Rank customers based on their CLTV.

```sql
select c.customer_id,
concat(c.first_name, ' ', c.last_name) as full_name,
round(sum(oi.quantity * oi.price_per_unit)::numeric,2) as cliv,
dense_rank() over (order by round(sum(oi.quantity * oi.price_per_unit)::numeric,2) desc)
from customers as c
inner join orders as o
using(customer_id)
inner join order_items as oi
using (order_id)
group by c.customer_id
```


8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.

```sql
select * 
from products as p
left join inventory as inv
using (product_id)
where inv.stock < 10
```

9. Shipping Delays
Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.

```sql
select * , shipping_date - order_date as delay
from orders as o
left join shipping as s
using (order_id)
where shipping_date - order_date > 3
```

10. Payment Success Rate 
Calculate the percentage of successful payments across all orders.
Challenge: Include breakdowns by payment status (e.g., failed, pending).

```sql
with o as(
select payment_status, count(payment_status) as counted
from payments
group by payment_status)

select *,
round(counted/(select sum(counted) from o)*100, 2) as percent
from o
```

11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
Challenge: Include both successful and failed orders, and display their percentage of successful orders.

```sql
WITH top_sellers
AS
(SELECT 
	s.seller_id,
	s.seller_name,
	SUM(oi.total_sale) as total_sale
FROM orders as o
JOIN
sellers as s
ON o.seller_id = s.seller_id
JOIN 
order_items as oi
ON oi.order_id = o.order_id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 5
),

sellers_reports
AS
(SELECT 
	o.seller_id,
	ts.seller_name,
	o.order_status,
	COUNT(*) as total_orders
FROM orders as o
JOIN 
top_sellers as ts
ON ts.seller_id = o.seller_id
WHERE 
	o.order_status NOT IN ('Inprogress', 'Returned')
	
GROUP BY 1, 2, 3
)
SELECT 
	seller_id,
	seller_name,
	SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END) as Completed_orders,
	SUM(CASE WHEN order_status = 'Cancelled' THEN total_orders ELSE 0 END) as Cancelled_orders,
	SUM(total_orders) as total_orders,
	SUM(CASE WHEN order_status = 'Completed' THEN total_orders ELSE 0 END)::numeric/
	SUM(total_orders)::numeric * 100 as successful_orders_percentage
	
FROM sellers_reports
GROUP BY 1, 2
```


12. Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/


```sql
select *, 
round(price-cogs::numeric) as margin,
dense_rank() over (order by round(price-cogs::numeric) desc)
from products
```

13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.

```sql
with s as (
select p.product_id, p.product_name, count(o.order_status) as total_returns
from orders as o
left join order_items as oi
using (order_id)
left join products as p
using (product_id)
where o.order_status = 'Returned'
group by 1, 2, order_status
order by total_returns desc
limit 10),

t as (select p.product_id, p.product_name, count(o.order_status) as total_status
from orders as o
left join order_items as oi
using (order_id)
left join products as p
using (product_id)
group by 1, 2
order by total_status desc)

select product_id, total_returns, total_status, 
round(total_returns::numeric/total_status::numeric*100, 2) as percent_returns
from s
inner join t
using (product_id)
```

14. Inactive Sellers
Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.

```sql
with w as (
with v as (
select seller_id, seller_name, count(*) 
from sellers as s
left join orders as o
using (seller_id)
where order_date >= current_date - interval '18 months'
group by 1, 2)

select s.seller_id, s.seller_name, count
from sellers as s
left join v
using (seller_id)
where count is null),

y as (select seller_id, sum(oi.quantity*oi.price_per_unit) as sales
from sellers as s
left join orders as o
using (seller_id)
left join order_items as oi
using (order_id)
group by 1
order by 1)

select * from w
left join y
using (seller_id)
```


15. IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns

```sql
with x as (
select c.customer_id, concat(c.first_name, ' ', c.last_name) as full_name,
count(*) as no_of_returns
from customers as c
left join orders as o
using (customer_id)
where order_status = 'Returned'
group by 1, 2)

select c.customer_id, c.first_name, c.last_name, x.no_of_returns,
case when no_of_returns > 5 then 'returning' else 'new' end as cus_type
from customers as c
left join x
using (customer_id)
```


16. Top 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer.
```sql
with y as (
select c.state, c.customer_id, count(*),
round(sum(quantity*price_per_unit)::numeric, 2) as total_sales,
dense_rank() over(partition by c.state order by count(*) desc) 
from orders as o
inner join customers as c
using (customer_id)
inner join order_items as oi
using (order_id)
group by 1, 2)

select * from y
where dense_rank <= 5;

```

17. Revenue by Shipping Provider
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.

```sql
with z as(
select *, round(oi.quantity*oi.price_per_unit::numeric, 2) as revenue,
shipping_date-order_date as delay
from shipping as s
left join order_items as oi
using (order_id)
left join orders as o
using (order_id)
)

select shipping_providers, count(*) as total_orders, 
sum(revenue) as total_revenue,
sum(delay)/count(*) as average_delay
from z
group by 1
```

18. Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result
Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year)

```sql
with ac as (
with ab as (
select * , quantity*price_per_unit as revenue, extract(year from order_date) as yearly
from order_items as oi
left join products as p
using (product_id)
left join orders as o
using(order_id)
)
select product_id, yearly, round(sum(revenue)) as total_sales1 from ab
where yearly = 2022
group by 1, 2),

ad as (with bb as (
select * , quantity*price_per_unit as revenue, extract(year from order_date) as yearly
from order_items as oi
left join products as p
using (product_id)
left join orders as o
using(order_id)
)
select product_id, yearly, round(sum(revenue)) as total_sales2 from bb
where yearly = 2023
group by 1, 2)

select *, round((total_sales2-total_sales1)/total_sales1*100) as DR from ac
left join ad
using(product_id)
order by dr
limit 10;
```


19. Final Task: Stored Procedure
Create a stored procedure that, when a product is sold, performs the following actions:
Inserts a new sales record into the orders and order_items tables.
Updates the inventory table to reduce the stock based on the product and quantity purchased.
The procedure should ensure that the stock is adjusted immediately after recording the sale.

```SQL
CREATE OR REPLACE PROCEDURE add_sales2
(
p_order_id INT,
p_customer_id INT,
p_seller_id INT,
p_order_item_id INT,
p_product_id INT,
p_quantity INT
)
LANGUAGE plpgsql
AS $$

DECLARE 
-- all variable
v_count INT;
v_price FLOAT;
v_product VARCHAR(50);

BEGIN
-- Fetching product name and price based p id entered
	SELECT 
		price, product_name
		INTO
		v_price, v_product
	FROM products
	WHERE product_id = p_product_id;
	
-- checking stock and product availability in inventory	
	SELECT 
		COUNT(*) 
		INTO
		v_count
	FROM inventory
	WHERE 
		product_id = p_product_id
		AND 
		stock >= p_quantity;
		
	IF v_count > 0 THEN
	-- add into orders and order_items table
	-- update inventory
		INSERT INTO orders(order_id, order_date, customer_id, seller_id)
		VALUES
		(p_order_id, CURRENT_DATE, p_customer_id, p_seller_id);

		-- adding into order list
		INSERT INTO order_items(order_item_id, order_id, product_id, quantity, price_per_unit)
         VALUES (p_order_item_id, p_order_id, p_product_id, p_quantity, v_price);

		--updating inventory
		UPDATE inventory
		SET stock = stock - p_quantity
		WHERE product_id = p_product_id;
		
		RAISE NOTICE 'Thank you product: % sale has been added also inventory stock updates',v_product; 

	ELSE
		RAISE NOTICE 'Thank you for for your info the product: % is not available', v_product;

	END IF;


END;
$$

```



**Testing Store Procedure**
call add_sales
(
25026, 2, 5, 25024, 1, 15
);

---

---

## **Learning Outcomes**

This project enabled me to:
- Design and implement a normalized database schema.
- Clean and preprocess real-world datasets for analysis.
- Use advanced SQL techniques, including window functions, subqueries, and joins.
- Conduct in-depth business analysis using SQL.
- Optimize query performance and handle large datasets efficiently.

---

## **Conclusion**

This advanced SQL project successfully demonstrates my ability to solve real-world e-commerce problems using structured queries. From improving customer retention to optimizing inventory and logistics, the project provides valuable insights into operational challenges and solutions.

By completing this project, I have gained a deeper understanding of how SQL can be used to tackle complex data problems and drive business decision-making.

---

### **Entity Relationship Diagram (ERD)**
![ERD]()

---
