with UniqueProducts_orders as (
select
	distinct
        p.product_id,
	c_dwh.craftsman_id,
	cu_dwh.customer_id,
	o.order_created_date,
	o.order_completion_date,
	o.order_status,
	NOW() as load_dttm
from
	source3.craft_market_orders o
join
        source3.craft_market_craftsmans c on
	o.craftsman_id = c.craftsman_id
join
        source3.craft_market_customers cu on
	o.customer_id = cu.customer_id
join
        dwh.d_products p on
	o.product_name = p.product_name
	and o.product_price = p.product_price
	and o.product_description = p.product_description
	and o.product_price = p.product_price
	and 3 = p.product_source
	and o.craftsman_id = p.product_craftsmans
join
        dwh.d_craftsmans c_dwh on
	c.craftsman_name = c_dwh.craftsman_name
	and c.craftsman_birthday = c_dwh.craftsman_birthday
	and c.craftsman_address = c_dwh.craftsman_address
	and c.craftsman_email = c_dwh.craftsman_email
join
        dwh.d_customers cu_dwh on
	cu.customer_name = cu_dwh.customer_name
	and cu.customer_birthday = cu_dwh.customer_birthday
	and cu.customer_address = cu_dwh.customer_address
	and cu.customer_email = cu_dwh.customer_email
union
select
	distinct 
        p.product_id,
	c_dwh.craftsman_id,
	cu_dwh.customer_id,
	o.order_created_date,
	o.order_completion_date,
	o.order_status,
	NOW() as load_dttm
from
	source2.craft_market_orders_customers o
join
        source2.craft_market_masters_products c on
	o.craftsman_id = c.craftsman_id
join
        dwh.d_products p on
	c.product_name = p.product_name
	and c.product_price = p.product_price
	and c.product_description = p.product_description
	and c.product_price = p.product_price
	and 2 = p.product_source
	and o.craftsman_id = p.product_craftsmans
join
        dwh.d_craftsmans c_dwh on
	c.craftsman_name = c_dwh.craftsman_name
	and c.craftsman_birthday = c_dwh.craftsman_birthday
	and c.craftsman_address = c_dwh.craftsman_address
	and c.craftsman_email = c_dwh.craftsman_email
join
        dwh.d_customers cu_dwh on
	o.customer_name = cu_dwh.customer_name
	and o.customer_birthday = cu_dwh.customer_birthday
	and o.customer_address = cu_dwh.customer_address
	and o.customer_email = cu_dwh.customer_email
union
select
	distinct 
        p.product_id,
	c_dwh.craftsman_id,
	cu_dwh.customer_id,
	o.order_created_date,
	o.order_completion_date,
	o.order_status,
	NOW() as load_dttm
from
	source1.craft_market_wide o
join
        dwh.d_products p on
	o.product_name = p.product_name
	and o.product_price = p.product_price
	and o.product_description = p.product_description
	and o.product_price = p.product_price
	and 1 = p.product_source
	and o.craftsman_id = p.product_craftsmans
join
        dwh.d_craftsmans c_dwh on
	o.craftsman_name = c_dwh.craftsman_name
	and o.craftsman_birthday = c_dwh.craftsman_birthday
	and o.craftsman_address = c_dwh.craftsman_address
	and o.craftsman_email = c_dwh.craftsman_email
join
        dwh.d_customers cu_dwh on
	o.customer_name = cu_dwh.customer_name
	and o.customer_birthday = cu_dwh.customer_birthday
	and o.customer_address = cu_dwh.customer_address
	and o.customer_email = cu_dwh.customer_email
)   
merge
into
	dwh.f_orders as target
		using UniqueProducts_orders as source
on
	(
    target.craftsman_id = source.craftsman_id
		and
    target.customer_id = source.customer_id
		and
    target.order_created_date = source.order_created_date
		and target.product_id = source.product_id
)
	when matched then
    update
set
	order_completion_date = case
		when target.order_completion_date <> source.order_completion_date then source.order_completion_date
		else target.order_completion_date
	end,
	order_status = case
		when target.order_status <> source.order_status then source.order_status
		else target.order_status
	end,
	load_dttm = case
		when target.order_completion_date <> source.order_completion_date
		or 
                 target.order_status <> source.order_status then NOW()
		else target.load_dttm
	end
	when not matched then
    insert
	(
    	product_id,
	craftsman_id,
	customer_id,
	order_created_date,
	order_completion_date,
	order_status,
	load_dttm
    )
values (
    	source.product_id,
        source.craftsman_id,
        source.customer_id,
        source.order_created_date,
        source.order_completion_date,
        source.order_status,
        source.load_dttm
    );