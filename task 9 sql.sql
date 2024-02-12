#1
SELECT product_code, product_name       
FROM dim_products                         
WHERE product_code IN (
    SELECT product_code
    FROM fact_events
    WHERE base_price >= 500 AND promo_type = 'BOGOF'
);

#2
select city,count(store_id) as store_count
from dim_stores
group by city
order by store_count desc;

# Created The View for promo Price
create view promo_price as
select *,
case
        when promo_type="50% OFF" then base_price*0.5
        when promo_type="25% OFF" then base_price*(1-0.25)
		when promo_type="33% OFF" then base_price*(1-0.33)
        when promo_type="BOGOF" then base_price*0.5
        when promo_type="500 Cashback" then base_price-500
        end as promo_price 
 from fact_events;

#3
select campaign_name,
		concat(round(sum(base_price*`quantity_sold(before_promo)`)/1000000)," M") as total_revenue_before_promotion,
        concat(round(Sum(promo_price*`quantity_sold(after_promo)`)/1000000)," M") as total_revenue_before_promotion
from promo_price
join dim_campaigns
using (campaign_id)
group by campaign_name;

#4
select 
rank() over( order by round(((sum(`quantity_sold(after_promo)`)-sum(`quantity_sold(before_promo)`))/
sum(`quantity_sold(before_promo)`))*100) desc) as rank_order,
category,
concat(round(((sum(`quantity_sold(after_promo)`)-sum(`quantity_sold(before_promo)`))/
sum(`quantity_sold(before_promo)`))*100, 2), " %") as "ISU%"
from fact_events
join dim_products
using (product_code)
join dim_campaigns
using (campaign_id)
where campaign_name = "Diwali"
group by category;


#5

select product_name,category,
		round(((sum(promo_price*`quantity_sold(after_promo)`)-sum(base_price*`quantity_sold(before_promo)`))/
		sum(base_price*`quantity_sold(before_promo)`))*100, 2) as IR_pct
from promo_price
join dim_products
using (product_code)
group by product_name, category 
order by IR_pct desc
limit 5;
        
        
			