use `retail_events_db`;

select * from dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;


 -----  Q1 ------
 
 SELECT DISTINCT p.product_name AS Product,
 f.base_price AS Base_Price,
 f.promo_type AS Promo_Type 
 FROM dim_products p
  JOIN
  fact_events f ON p.product_code = f.product_code
WHERE f.base_price > 500 AND f.promo_type = "BOGOF"  
ORDER BY base_price ASC;


------ Q2 --------

SELECT city AS City, COUNT(DISTINCT store_id) AS Store_Count
FROM dim_stores
GROUP BY City
ORDER BY Store_Count DESC;

------ Q3 ------
SELECT c.campaign_name AS Campaign_Name,
CONCAT(ROUND(SUM(f.base_price * f.quantity_sold_before_promo) / 1000000,2), ' M') AS Revenue_Before_Campaign,
CONCAT(ROUND(SUM(f.base_price * f.quantity_sold_after_promo) / 1000000,2), ' M') AS Revenue_after_Campaign
FROM dim_campaigns c
JOIN
fact_events f ON c.campaign_id = f.campaign_id
GROUP BY campaign_name
ORDER BY campaign_name; 

------ Q4 ------

SELECT p.category, 
Round((((Sum(quantity_sold_after_promo) - Sum(quantity_sold_before_promo)) / Sum(quantity_sold_before_promo)) * 100), 2) AS ISU_Percentage,
RANK() OVER (ORDER BY (((Sum(quantity_sold_after_promo) - Sum(quantity_sold_before_promo)) / Sum(quantity_sold_before_promo)) * 100) DESC) AS Rank_order
FROM dim_products AS p
INNER JOIN fact_events AS f
ON p.product_code = f.product_code
WHERE f.campaign_id = "CAMP_DIW_01"
GROUP BY p.category;

------ Q5 ------

 WITH product_ir_pct AS
	(SELECT 
		DISTINCT p.product_name AS Product,
		ROUND(((SUM(f.base_price*f.quantity_sold_after_promo) - SUM(f.base_price*f.quantity_sold_before_promo)) / SUM(f.base_price*f.quantity_sold_before_promo)) * 100,2) AS IR_Percentage
	FROM
		dim_products p
			JOIN
		fact_events f USING (product_code)
	GROUP BY product_name)
SELECT *,
	DENSE_RANK() OVER(ORDER BY IR_Percentage DESC ) as Rank_Order
FROM product_ir_pct
LIMIT 5 ;







