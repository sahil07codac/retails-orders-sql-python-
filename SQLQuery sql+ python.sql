select * from df_orders;

--find top 10 highest revenue generating product

select top 10 product_id,
round(sum(sale_price),2)as revenue from df_orders
group by product_id
order by revenue desc ;

---find top 5  highest selling product by earch region 
with cte as(
select region,product_id,round(sum(sale_price),2) as revenue , 
row_number() over (partition by region order by sum(sale_price) desc )as rn
from df_orders
group by  region,product_id)
select * from cte where rn<=5;

-- month over month  sales camparision for 2022 to 2023
select * from df_orders;

with cte as(
select year(order_date)as years, month(order_date)as months,
sum(sale_price)as revenue from df_orders
group by year(order_date), month(order_date))
select months ,
sum(case when years=2022 then revenue else 0 end)as revenue2022 ,
sum(case when years=2023 then revenue else 0 end)as revenue2023 
from cte 
group by months;



---for each category which month had highest sale
with cte as (
select year(order_date)as years,month(order_date)as months,category, 
sum(sale_price)as revneue from df_orders
group by year(order_date),month(order_date),category), s as(
select *, row_number() over (partition by category order by revneue desc )as rn  from cte )
select category, months from s
where rn =1;
---or 
with cte as(
select format(order_date,'yyyyMM')AS months ,category,sum(sale_price)as revenue 
,row_number() over(partition by category order by sum(sale_price)  desc)as rn from df_orders
group by format(order_date,'yyyyMM'),category )
select category, months from cte
where rn=1;
---


--- which subcategory has highest  growth by profit  in 2023 compare to 2022
with cte as(
select year(order_date)as years,sub_category, 
sum(profit)as profit from df_orders
group by  year(order_date),sub_category),
sd as(
select sub_category,sum(case when years=2023 then profit else 0 end )as years2023 ,
sum(case when years=2022 then profit else 0 end)  as years2022 from cte 
group by sub_category)
select top 1 *,(years2023-years2022) as growth  from sd
order by  growth desc;


----or-- sale price comaprision

with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
--order by year(order_date),month(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select top 1 *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc;