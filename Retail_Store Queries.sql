Create database Retail_Store;

CREATE TABLE customers
(
customer_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL,
email VARCHAR(100) NOT NULL UNIQUE,
phone VARCHAR(15),
created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products
(
product_id INT PRIMARY KEY AUTO_INCREMENT,
name VARCHAR(100) NOT NULL,
category VARCHAR(50) NOT NULL,
price DECIMAL(10,2) NOT NULL,
stock_quantity INT NOT NULL DEFAULT 0,
added_on DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders
(
order_id INT PRIMARY KEY AUTO_INCREMENT,
customer_id INT,
order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
status VARCHAR(20) DEFAULT 'Pending',
total_amount DECIMAL(10,2),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items
(
order_item_id INT PRIMARY KEY AUTO_INCREMENT,
order_id INT,
product_id INT,
quantity INT NOT NULL CHECK (quantity > 0),
item_price DECIMAL(10,2) NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(order_id),
FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments
(
payment_id INT PRIMARY KEY AUTO_INCREMENT,
order_id INT,
payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
amount_paid DECIMAL(10,2) NOT NULL CHECK (amount_paid > 0),
method VARCHAR(20) NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE product_reviews
(
review_id INT PRIMARY KEY AUTO_INCREMENT,
product_id INT,
customer_id INT,
rating INT NOT NULL,
review_text TEXT,
review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY (product_id) REFERENCES products(product_id),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-------------------------------- BASIC LEVEL INFORMATION ----------------------------

Select * from customers;
Select * from products;
Select * from orders;
Select * from order_items;
Select * from payments;
Select * from product_reviews;

# Customer details
Select name,email from customers;

# Various Product categories
Select distinct category From products;

# List of Medium value Products
Select name as Product_name, price from products
Where price > 1000;

# List of High value Products
Select name as Product_name,price from products
Where (price > 2000) AND (price < 5000);

# List of Low value Products
Select name as Product_name, price from products
Where price < 1000;

# Identify Selective Customers
Select * from customers
Where customer_id in(18,23,28,30);

Select * from customers
Where name like 'A%';

# List of Category Specific Medium value Products
Select * from products
Where (category = 'Electronics') And (price < 3000);

# Top Priced items 
Select name as Product_name, price from products
Order by price desc;

Select name,price from products
Order by price desc,name asc;

----------------------------- FILTERING AND FORMATTING ----------------------------

Select * from customers
Where customer_id is NULL;

Select name as Customer_name , email as Customer_Email_adress
From customers;

# Total Value Per Item
Select order_item_id, order_id, product_id, quantity, item_price,
	quantity * item_price as Total_value
From order_items;

Select payment_id, order_id,
	Date(payment_date) as Payment_date, amount_paid
From payments
Order by Payment_date;

Select concat(name,'-',phone) as Customer_Contact_number
From customers;

# Date Wise Order Reporting
Select order_id, customer_id,
	Date(order_date) as Order_date
From orders;

# Not Available Products
Select name as Product_name,stock_quantity
From products
Where stock_quantity = 0;

# More Than One Order Items
Select order_id, product_id, quantity
From order_items
Where quantity > 1;

-------------------------------- AGGRIGATIONS -------------------------------

# Total Orders Placed
Select count(order_id) as Total_orders
From orders;

# Total Revenue Collection
Select sum(total_amount) as Total_revenue
From orders;

# Average Order Value
Select round(avg(total_amount),1) as Average_order_value
From orders;

# Customers That Placed At Least One Order
Select customer_id, count(order_id) as Total_orders
From orders
Group by customer_id;

# Total Sales Amount Per Customer
Select customer_id, sum(total_amount) as Total_sales_amount
From orders
Group by customer_id;

# Number Of Products Sold Per Category
SELECT P.category, SUM(OI.quantity) AS Total_products_sold
FROM order_items OI
JOIN products P
ON OI.product_id = P.product_id
GROUP BY P.category;

# Order Based Total Item Price
Select order_id, sum(item_price) as Total_item_price
From order_items
Group by order_id;

# Average Item Price Per Category 
Select category, round(avg(price),1) as Average_price
From products
Group by category;

# Product Based Stock Quantities
Select name as Product_name, sum(stock_quantity) as Stock_quantity
From products
Group by Product_name
Order by Stock_quantity Desc;

# Track Date Wise Placed Orders
Select Date(order_date) as Order_date,
count(order_id) as Orders_per_day
From orders
Group by Date(order_date)
Order by order_date;

# Amount Per Order Status To Track Revenue Recieved, Pending And Cancelled
Select status as Order_status, sum(total_amount) as Total_sales_amount
From orders
Group by Order_status
Order by Total_sales_amount;

# Total Payments Received Per Payment Method
Select method as payment_method,
Sum(amount_paid) as Total_payment
From payments
Group by method
Order by Total_payment desc;
-------------------------------------- MULTI TABLE QUERIES --------------------------------

# Order Details Along With Customer Name
Select C.name as Customer_name, C.customer_id, O.order_id, O.order_date, O.status, O.total_amount
From customers as C
Inner Join orders as O
On C.customer_id = O.customer_id;

# Products That Are Included In Orders
Select P.name as Product_name,P.category, P.product_id, O.quantity, O.item_price
From products as P
Inner Join order_items as O
On P.product_id = O.product_id;

# Payment Method Used For Order
Select O.order_id, O.order_date, O.status, P.method as Payment_method, p.amount_paid
From orders as O
Inner Join payments as P
On O.order_id = P.order_id;

# Product Based Reviews For Quality Check
Select C.name as Customer_name, C.email as Email_address, C.phone as Contact_number,
	PR.rating, PR.review_text,
    P.name as Product_name, P.category
From customers as C
Inner Join product_reviews as PR
On C.customer_id = PR.customer_id
Inner Join products as P
On PR.product_id = P.product_id;

# Customers Who Have Or Have Not Placed Ordered
Select C.*, O.Order_id
From customers as C
Left join orders as O
On C.customer_id = O.customer_id;

# Products That Are Sold And Also Product That Remained Unsold
Select P.name as Product_name, P.category, P.price, sum(O.quantity) as Quantity
From products as P
Left join order_items as O
On P.product_id = O.product_id
Group by P.product_id, P.name
Order by Quantity desc;

# All Payments With Matching Orders Along With No Placed Orders
Select P.payment_id,
	Date(P.payment_date) as Payment_date, P.amount_paid, P.method, O.order_id
From payments as P
Right join orders as O
On P.order_id = O.order_id;

# Customer Order and Payment Details
Select C.name as Customer_name, O.order_id, O.status, P.amount_paid, P.method
From customers as C
Join orders as O
On C.customer_id = O.customer_id
Join payments as P
On O.order_id = P.order_id;

-------------------------------------- QUERIES -------------------------------------

# Above Average Value Products
Select * From products
Where price >
(
Select avg(price)
From products
);

# Customers Who Have Placed At Least One Order
Select * from customers
Where customer_id in 
(
Select Distinct customer_id
From orders
);

# Above Average Priced Orders Each Customer
Select * from
(
Select C.name as Customer_name, C.customer_id, O.order_id, O.total_amount
From customers as C
Inner Join orders as O
On C.customer_id = O.customer_id
) as Highvalue_customer
Where total_amount >
(
Select avg(total_amount)
From orders
);

# Customers Who Have Not Placed Orders
Select * from customers
Where customer_id not in 
(
Select Distinct customer_id
From orders
);

# Products That Are Not Ordered
Select * from products
Where product_id not in 
(
Select Distinct product_id
From order_items
);

# Highest Order Value Placed By Each Customer
Select C.name as Customer_name, C.customer_id, max(O.total_amount) as Highest_Order_Value
From customers as C
Inner Join orders as O
On C.customer_id = O.customer_id
Group by C.customer_id, C.name;

-------------------------------------- SET OPERATIONS ------------------------------------

# Customers that placed order or gave review
SELECT customer_id
FROM orders
UNION
SELECT customer_id
FROM product_reviews;

# Customers that placed order as well as gave review
SELECT DISTINCT customer_id FROM orders
WHERE customer_id IN
(
SELECT customer_id
FROM product_reviews
);