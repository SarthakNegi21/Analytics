#find top 10 highest revenue generating products

Select product_id,round(sum(sale_price),2) as revenue
from df_orders
group by product_id
order by revenue desc
limit 10;

#find top 5 highest selling products in each region

with cte as (Select region,product_id,round(sum(sale_price),2) as revenue,
dense_rank() over (partition by region order by sum(sale_price) desc) as rnk
from df_orders
group by region,product_id)
Select region,product_id,revenue from cte where rnk <= 5
order by region;

#find month over month growth comparison for 2022 and 2023 sales

with cte as (Select month(order_date) as mnth_num,date_format(order_date,'%M') as mnth,
round(sum(case when year(order_date) = 2022 then sale_price end),2) as revenue_2022,
round(sum(case when year(order_date) = 2023 then sale_price end),2) as revenue_2023
from df_orders df
group by month(order_date),date_format(order_date,'%M')
order by month(order_date))
Select mnth,round(((revenue_2023-revenue_2022)/revenue_2022)*100,2)as mom_growth from cte;


#find out month with highest sales for each category

with cte as (Select category,date_format(order_date,'%Y-%m') as order_month,sum(sale_price) as revenue,
dense_rank() over (partition by category order by sum(sale_price) desc) as rnk
from df_orders
group by category,date_format(order_date,'%Y-%m'))
Select category,order_month,round(revenue,2)
from cte
where rnk = 1;


#find the sub-category which has highest growth by profit in 2023 compared to 2022
with cte as (Select sub_category,
sum(case when year(order_date) = 2022 then profit else 0 end) as profit_2022,
sum(case when year(order_date) = 2023 then profit else 0 end) as profit_2023
from df_orders
group by sub_category)
Select sub_category,profit_2022,profit_2023,round((profit_2023 - profit_2022),2) yoy_profit
from cte
order by yoy_profit desc
limit 1;
