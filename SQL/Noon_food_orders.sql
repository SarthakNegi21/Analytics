#Top outlet by cuisine without using limit and top function

with cte as (Select cuisine,restaurant_id,count(*) no_of_orders,
rank() over (partition by cuisine order by count(*) desc) rnk
from orders
group by cuisine,restaurant_id)
Select cuisine,restaurant_id
from cte
where rnk = 1;


#Find the daily new customer count from the launch date (new customers acquired each day)
with cte as (Select customer_code,count(*),min(date_format(placed_at,'%Y-%m-%d')) order_date
from orders
group by customer_code)
Select order_date,count(*) as unique_user
from cte
group by order_date
order by order_date;


#Find all the users who were acquired in Jan-2025 and only placed one order in Jan and did not placed any other order
with cte as (Select customer_code,count(*)
from orders
where date_format(placed_at,'%Y-%m') = '2025-01'
group by customer_code
having count(*) = 1)
Select o.customer_code
from orders o join cte
on o.customer_code = cte.customer_code
and o.customer_code not in (Select distinct customer_code from orders where date_format(placed_at,'%Y-%m') > '2025-01');


#List all the customers with no order in the last 7 days but were acquired one month ago with their first order on promo
with cte as (Select customer_code,min(date_format(placed_at,'%Y-%m-%d'))
from orders 
where placed_at  < date_sub(date('2025-03-31'), interval 1 month)
and promo_code_name is not null
group by customer_code)
Select customer_code
from cte 
where customer_code not in (
Select distinct customer_code from orders
where date_format(placed_at,'%Y-%m-%d') between date_sub(date('2025-03-31'), interval 7 day) and date('2025-03-31')
);


#Growth team is planning to create a trigger that will target customers after their every third order
#with a personlized communication. Identify the required list of customers.
with cte as (Select customer_code,placed_at,rank() over (partition by customer_code order by placed_at) as rnk
from orders)
Select customer_code,placed_at 
from cte where rnk%3=0
and date_format(placed_at,'%Y-%m-%d') = current_date() - 1;


#List customers who placed more than 1 order and all their orders are promo only
Select customer_code,count(customer_code) no_of_orders,count(promo_code_name) orders_on_promo
from orders
group by customer_code
having count(customer_code) > 1 
and count(customer_code) = count(promo_code_name);


#What percentage of customers were organically acquired in Jan 2025(placed first order without promo code)
with cte as (Select customer_code,min(placed_at) order_date
from orders 
where year(placed_at)=2025
and month(placed_at)=01
group by customer_code)
Select 100*(count(case when o.customer_code = cte.customer_code
and o.placed_at = cte.order_date
and o.promo_code_name is null then 1 end)/count(distinct cte.customer_code)) as organic_cust_perc
from orders o join cte;