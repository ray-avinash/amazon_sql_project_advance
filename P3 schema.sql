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









