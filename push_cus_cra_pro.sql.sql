with UniqueProducts_craftsmans as (
select
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email,
	NOW() as load_dttm
from
	source3.craft_market_craftsmans cmc
group by
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email
union
select
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email,
	NOW() as load_dttm
from
	source2.craft_market_masters_products
group by
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email
union
select
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email,
	NOW() as load_dttm
from
	source1.craft_market_wide
group by
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email
)
merge
into
	dwh.d_craftsmans as target
		using UniqueProducts_craftsmans as source
on
	(
    target.craftsman_name = source.craftsman_name
		and 
    target.craftsman_birthday = source.craftsman_birthday
)
	when matched then
    update
set
	craftsman_address = case
		when target.craftsman_address <> source.craftsman_address then source.craftsman_address
		else target.craftsman_address
	end,
	craftsman_email = case
		when target.craftsman_email <> source.craftsman_email then source.craftsman_email
		else target.craftsman_email
	end,
	load_dttm = case
		when target.craftsman_email <> source.craftsman_email
		or 
                 target.craftsman_address <> source.craftsman_address then NOW()
		else target.load_dttm
	end
	when not matched then
    insert
	(
        craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email,
	load_dttm
    )
values (
        source.craftsman_name,
        source.craftsman_address,
        source.craftsman_birthday,
        source.craftsman_email,
        source.load_dttm
    );
  
   
   
 --------------------------------------------------------------------------------------  
WITH UniqueProducts_customers AS (
    SELECT
        customer_name,
        customer_address,
        customer_birthday,
        customer_email,
        NOW() AS load_dttm
    FROM
        source3.craft_market_customers
    GROUP BY
        customer_name,
        customer_address,
        customer_birthday,
        customer_email
    union 
    SELECT
        customer_name,
        customer_address,
        customer_birthday,
        customer_email,
        NOW() AS load_dttm
    FROM
        source2.craft_market_orders_customers 
    GROUP BY
        customer_name,
        customer_address,
        customer_birthday,
        customer_email
    union 
    SELECT
        customer_name,
        customer_address,
        customer_birthday,
        customer_email, 
        NOW() AS load_dttm
    FROM
        source1.craft_market_wide
    GROUP BY
        customer_name,
        customer_address,
        customer_birthday,
        customer_email
)
MERGE INTO dwh.d_customers AS target
USING UniqueProducts_customers AS source
ON (
    target.customer_name = source.customer_name AND
    target.customer_birthday = source.customer_birthday 
)
WHEN MATCHED THEN
    UPDATE SET
        customer_address = CASE 
            WHEN target.customer_address <> source.customer_address THEN source.customer_address 
            ELSE target.customer_address 
        END,
        customer_email = CASE 
            WHEN target.customer_email <> source.customer_email THEN source.customer_email 
            ELSE target.customer_email 
        END,
        load_dttm = CASE 
            WHEN target.customer_email <> source.customer_email OR 
                 target.customer_address <> source.customer_address THEN NOW() 
            ELSE target.load_dttm 
        END
WHEN NOT MATCHED THEN
    INSERT (
        customer_name,
        customer_address,
        customer_birthday,
        customer_email,
        load_dttm
    )
    VALUES (
        source.customer_name,
        source.customer_address,
        source.customer_birthday,
        source.customer_email,
        source.load_dttm
    );   

----------------------------------------------------------------------------------
WITH UniqueProducts AS (
    SELECT DISTINCT
        product_name,
        product_description,
        product_type,
        product_price, 
        NOW() AS load_dttm,
        3 AS product_source,  -- источник 3
        craftsman_id
    FROM
        source3.craft_market_orders
    
    UNION 
    
    SELECT DISTINCT
        product_name,
        product_description,
        product_type,
        product_price,
        NOW() AS load_dttm,
        2 AS product_source,  -- источник 2
        craftsman_id
    FROM
        source2.craft_market_masters_products
    
    UNION 
    
    SELECT DISTINCT
        product_name,
        product_description,
        product_type,
        product_price, 
        NOW() AS load_dttm,
        1 AS product_source,  -- источник 1
        craftsman_id
        
    FROM
        source1.craft_market_wide
)
MERGE INTO dwh.d_products AS target
USING (
    SELECT 
        o.product_source,
        o.product_name,
        o.product_description,
        o.product_type,
        o.product_price, 
        NOW() AS load_dttm,
        o.craftsman_id
    FROM
        UniqueProducts o
) AS source
ON (
    target.product_source = source.product_source and  target.product_name = source.product_name
    and target.product_description = source.product_description and target.product_type = source.product_type
    and target.product_craftsmans = source.craftsman_id
)
WHEN MATCHED THEN
    UPDATE SET
        product_price = CASE 
            WHEN target.product_price <> source.product_price THEN source.product_price 
            ELSE target.product_price 
        END,
        load_dttm = CASE 
            WHEN 
                 target.product_price <> source.product_price
                 THEN NOW() 
            ELSE target.load_dttm 
        END
WHEN NOT MATCHED THEN
    INSERT (
    product_source,
        product_name,
        product_description,
        product_type,
        product_price,
        load_dttm,
        product_craftsmans
    )
    VALUES (
    source.product_source,
        source.product_name,
        source.product_description,
        source.product_type,
        source.product_price,
        source.load_dttm,
        source.craftsman_id
        
    );