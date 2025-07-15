# CREATED DATABASE, TABLE AND INSERTED RECORDS USING TABLE IMPORT WIZARD #

create database amazon_sales;
Use amazon_sales;


create table sales
(
Order_ID varchar(15) primary key,
Date date,
Product varchar(25),
Category varchar(25),
Price float,
Quantity tinyint,
Total_Sales float,
Customer_Name  varchar(25),
Customer_Location varchar(25),
Payment_Method varchar(20),
Status varchar(15)
);


# DATA EXPLORATION #

select * from sales; 

select count(*) as total_count from sales; -- We have 11 Columns and 250 Rows

select distinct(month(Date)) as months from sales order by months; 
-- We have data for 3 months (Feb, March and April) of year 2025

select distinct	Category from sales;
-- Footwear, Electronics, Clothing, Books & Home Appliances (5 distinct Categories)

select distinct	Payment_Method from sales;
-- Debit Card, Amazon Pay, Credit Card, PayPal & Gift Card (5 distinct Payment Methods)

select Order_ID, count(*) from sales 
group by Order_ID
having count(*) > 1;
-- No duplicate records found

select
  sum(case when `Product` is null then 1 else 0 end) as null_product,
  sum(case when `Date` is null then 1 else 0 end) as null_date,
  sum(case when `Total_Sales` is null then 1 else 0 end) as null_total_sales
from sales;                                                                  
  -- No null records found in the above columns  




# BASIC DATA ANALYSIS #

-- 1. What is the total sales amount generated in 2025?

select sum(Total_Sales) from sales
 where year(Date) = 2025;             
 -- 243845

-- 2. How many unique products were sold, and what are they?

select count(distinct Product) Unique_Product_Count from sales; 
-- 10 products

select distinct Product from sales;
-- Running Shoes, Headphones, Smartwatch, T-Shirt, Smartphone, Book, Jeans, Laptop, Washing Machine & Refrigerator

-- 3. Which payment method was used the most?

select Payment_Method, count(*) as usage_count from sales
 group by  Payment_Method 
 order by usage_count desc                    
 limit 1;						                      
 -- PayPal is used the most (60 out of 250 times)
 
 
 -- 4. How many orders were Completed, Pending, or Cancelled?

select Status, count(*) as total_count from sales
group by Status;                                    
 -- 77 Cancelled, 85 Pending, 88 Completed


-- 5. Which product category generated the highest total sales revenue?

select Category, sum(Total_Sales) as total_revenue from sales
group by Category
order by total_revenue desc limit 1;                                     
-- Electronics	129950


-- 6. Who are the top 5 customers based on total sales?

select Customer_Name, sum(Total_Sales) as total_sales from sales
group by Customer_Name  
order by total_sales desc limit 5;

-- Olivia Wilson  36170
-- Jane Smith	    31185
-- Emma Clark	    29700
-- John Doe	      26870
-- Emily Johnson  23475


-- 7. What is the monthly trend of sales in 2025?

select * from sales;

select month(Date) as month, 
       sum(Total_Sales) as total_sales from sales
where year(Date) = 2025
group by month
order by total_sales desc;       
-- Sales peaked in 2nd month of year 2025 but the opposite happened in the 4th month.


-- 8. Which product had the highest sales volume (by quantity)?

select Product, sum(Quantity) as total_sold_quantity from sales
group by Product 
order by total_sold_quantity desc 
limit 1;                                                             
-- Smartwatch-105


-- 9. Which cities contributed the most to overall sales?

select Customer_Location, sum(Total_Sales) as total_sales from sales
group by Customer_Location 
order by total_sales desc limit 5;                                  
 -- Miami-31700


-- 10. What is the average order value (AOV) per month?

select month(Date) as month, 
round(avg(Total_Sales), 1) as avg_order_value from sales
group by month 
order by month;

-- 2nd-1085.8
-- 3rd-898.7
-- 4th-570


-- 11. Which customers made multiple purchases (repeat customers)?

select Customer_Name, count(Order_ID) as purchases from sales
group by Customer_Name
having purchases > 1
order by purchases desc;
-- Emma Clark did 32 and Sophia Miller did 16 purchases out of total 10 customers who did multiple purchases.


-- 12. What is the order completion rate (percentage of completed vs total orders)?

select (select count(*) from sales
        where Status = 'Completed')*100/count(*) as completion_rate from sales;
 -- 35.20%
 
 
 -- 13. What is the top-selling product in each category?

 with cte1 as
     (select Category, Product, sum(Quantity) as sold_quantity,
      dense_rank() over (partition by Category order by sum(Quantity) desc) as ranked
      from sales
      group by Category, Product)
select Category, Product, sold_quantity from cte1
where ranked = 1
order by sold_quantity desc;

-- Electronics	    Smartwatch	  105
-- Footwear	        Running Shoes	72
-- Books	          Book	        69
-- Home Appliances	Refrigerator	65
-- Clothing	        Jeans	        62


-- 14. Which popular products also had high cancellation rates?

with cte1 as (
      select Product, 
       sum(case when Status = 'Cancelled' then Quantity else 0 end) as cancelled_order_count,  
       sum(Quantity) as sold_quantity
     from sales
     group by Product
     having sum(Quantity) >= 50    # Assuming Products sold 50 or more times are popular # 
      )
select *, 
       round((cancelled_order_count/sold_quantity)*100,1) as cancellation_rate
from cte1 
order by cancellation_rate desc
limit 3;                     -- focusing only on the top 3 products with highest popularity & cancellation rate. 

-- Headphones	  43.8
-- Jeans	      38.7
-- Refrigerator	30.8

-- 15. What is the month-over-month (MoM) sales growth percentage?

with cte1 as
     (
     select month(Date) as month, sum(Total_Sales) as current_month_sales
     from sales
     group by  month(Date)
     order by month(Date)
     ),
cte2 as
     (
     select *, lag(current_month_sales) over() as previous_month_sales
     from cte1
     )
     select *, 
     round((current_month_sales-previous_month_sales)*100/previous_month_sales,2) as mom_growth_rate
     from cte2 
-- as per results there is a 4.05% decline in growth rate on the 2nd month 
-- but major drop of 97.1% on the 3rd month. 

