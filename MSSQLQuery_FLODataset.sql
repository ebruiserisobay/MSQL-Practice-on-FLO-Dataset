-- Query to show how many different customers made a purchase:
select 
    count(distinct master_id) unique_customers
from 
    Customers.dbo.FLO

-----------

-- Query to retrieve the total number of purchases and revenue:
select 
    sum(order_num_total_ever_online)+sum(order_num_total_ever_offline) order_num_total,
    sum(customer_value_total_ever_offline)+sum(customer_value_total_ever_online) total_value
from 
    Customers.dbo.FLO

-----------

-- Query to retrieve the average revenue per purchase:
select 
    sum((customer_value_total_ever_offline)+(customer_value_total_ever_online)) / sum(order_num_total_ever_online+order_num_total_ever_offline) avg_value
from 
    Customers.dbo.FLO

-----------

-- Query to retrieve the total revenue and number of purchases made through the last order channel (last_order_channel):
select 
    last_order_channel, 
    sum(order_num_total_ever_online)+sum(order_num_total_ever_offline) order_num_total,
    sum(customer_value_total_ever_offline)+sum(customer_value_total_ever_online) total_value
from 
    Customers.dbo.FLO
group by 
    last_order_channel

-----------

-- Query to retrieve the total revenue obtained by store type:
select 
    store_type, 
    sum(customer_value_total_ever_offline) + sum(customer_value_total_ever_online) total_value
from 
    Customers.dbo.FLO
group by 
    store_type

-----------

-- Query to retrieve the number of purchases broken down by year: (Based on the year of the customer’s first order date (first_order_date))
select 
    datepart(year, first_order_date)  first_order_year,
    sum(order_num_total_ever_online) + SUM(order_num_total_ever_offline)  order_num_total
from 
    Customers.dbo.FLO
group by
    datepart(year, first_order_date)
order by 
    first_order_year desc

-----------

-- 8. Query to calculate the average revenue per purchase broken down by the last order channel:
select 
    last_order_channel ,
    sum(customer_value_total_ever_offline + customer_value_total_ever_online) / sum(order_num_total_ever_offline + order_num_total_ever_online) avg_value
from 
    Customers.dbo.FLO
group by 
    last_order_channel

-----------

-- Query to retrieve the most popular category in the last 12 months:
select top 1 
    interested_in_categories_12 , 
    sum(order_num_total_ever_online + order_num_total_ever_offline) order_num_total
from 
    Customers.dbo.FLO
group by 
    interested_in_categories_12
order by 
    order_num_total desc

-----------

-- Query to retrieve the most preferred store_type:
select top 1 
    store_type , 
    sum(order_num_total_ever_online + order_num_total_ever_offline) order_num_total
from 
    Customers.dbo.FLO
group by 
    store_type
order by 
    order_num_total desc

-----------

-- Query to retrieve the most popular category based on the last order channel (last_order_channel) and the amount of purchases made in that category:

select 
    distinct last_order_channel,
(
	select top 1 
        interested_in_categories_12 
	from 
        Customers.dbo.FLO  
    where 
        last_order_channel=flo.last_order_channel
	group by 
        interested_in_categories_12
	order by 
	    sum(order_num_total_ever_online + order_num_total_ever_offline) desc 
),
(
	select top 1 
        sum(order_num_total_ever_online + order_num_total_ever_offline) 
	from 
        Customers.dbo.FLO  
    where 
        last_order_channel=flo.last_order_channel
	group by 
        interested_in_categories_12
	order by 
	    sum(order_num_total_ever_online + order_num_total_ever_offline) desc 
)
from Customers.dbo.FLO flo


-----------

-- Query to retrieve the ID of the person who made the most purchases:
select 
    master_id 
from 
    (select 
        top 1
        master_id,
        sum(order_num_total_ever_online + order_num_total_ever_offline) order_num_total
    from
        Customers.dbo.FLO
    group by 
        master_id
    order by 
        order_num_total desc) customer_info


-----------

-- Query to retrieve the average revenue per purchase and the average days between purchases (purchase frequency) of the person who made the most purchases:

select top 1
    avg_value,
    (active_days / order_num_total) avg_active_days  
from 
    (select 
        master_id,
        datediff(day,first_order_date, last_order_date) active_days,
        sum(order_num_total_ever_online + order_num_total_ever_offline) order_num_total,
        sum(customer_value_total_ever_offline + customer_value_total_ever_online) / sum(order_num_total_ever_offline + order_num_total_ever_online) avg_value
    from
        Customers.dbo.FLO
    group by 
        master_id, datediff(day,first_order_date, last_order_date)) best_customer
order by 
    order_num_total desc


-----------

-- Query to retrieve the average days between purchases (purchase frequency) of the top 100 people who made the most purchases (based on revenue)
select top 100
    (active_days / order_num_total) avg_active_days  
from 
    (select 
        master_id,
        datediff(day,first_order_date, last_order_date) active_days,
        sum(order_num_total_ever_online + order_num_total_ever_offline) order_num_total,
        sum(customer_value_total_ever_offline)+sum(customer_value_total_ever_online) total_value
    from
        Customers.dbo.FLO
    group by 
        master_id, datediff(day,first_order_date, last_order_date)) best_customer
order by 
    total_value desc


-----------

-- Query to retrieve the customer who made the most purchases broken down by the last order channel (last_order_channel):

select 
    distinct last_order_channel,
(
	select 
        top 1 
        master_id
	from 
        Customers.dbo.FLO  
    where 
        last_order_channel = flo.last_order_channel
	group by 
        master_id
	order by 
	    sum(customer_value_total_ever_offline + customer_value_total_ever_online) desc 
) best_customer,
(
	select 
        top 1 
        sum(customer_value_total_ever_offline + customer_value_total_ever_online)
	from 
        Customers.dbo.FLO  
    where
        last_order_channel = flo.last_order_channel
	group by 
        master_id
	order by 
	    sum(customer_value_total_ever_offline + customer_value_total_ever_online) desc 
) total_value 
from 
    Customers.dbo.FLO flo

-----------

-- Query to retrieve the ID of the person who made the most recent purchase: (If there are multiple IDs with the same max last order date, they are also included.)

select 
    master_id
from 
    Customers.dbo.FLO
where 
    last_order_date = (select max(last_order_date) from Customers.dbo.FLO);

