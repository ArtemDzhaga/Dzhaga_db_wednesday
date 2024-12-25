-- Мердж витрины  
merge
into
	dwh.craftsman_report_datamart as target
		using (
	select
		c.craftsman_id,
		-- идентификатор мастера
		c.craftsman_name,
		-- ФИО мастера
		c.craftsman_address,
		-- адрес мастера
		c.craftsman_birthday,
		-- дата рождения мастера
		c.craftsman_email,
		-- электронная почта мастера
		SUM(case when o.order_status = 'done' then p.product_price * 0.9 else 0 end) as craftsman_money,
		-- сколько заработал мастер
		SUM(case when o.order_status = 'done' then p.product_price * 0.1 else 0 end) as platform_money,
		-- сколько заработала платформа
		COUNT(o.order_id) as count_order,
		-- общее количество заказов за месяц
		SUM(case when o.order_status = 'done' then p.product_price else 0 end) as avg_price_order,
		-- сколько с заказов получено
		AVG(extract(year from AGE(cu.customer_birthday))) as avg_age_customer,
		-- средний возраст покупателей
		PERCENTILE_CONT(0.5) within group (
		order by o.order_completion_date - o.order_created_date) as median_time_order_completed,
		-- медианное время выполнения заказов
        (
		select
			p2.product_type
		from
			dwh.d_products p2
		join dwh.f_orders o2 on
			p2.product_id = o2.product_id
		where
			o2.craftsman_id = c.craftsman_id
		group by
			p2.product_type
		order by
			COUNT(*) desc
		limit 1) as top_product_category,
		-- самая популярная категория товаров у мастера
		COUNT(case when o.order_status = 'created' then 1 end) as count_order_created,
		-- количество созданных заказов за месяц
		COUNT(case when o.order_status = 'in progress' then 1 end) as count_order_in_progress,
		-- количество заказов в процессе изготовления за месяц
		COUNT(case when o.order_status = 'delivery' then 1 end) as count_order_delivery,
		-- количество заказов в доставке за месяц
		COUNT(case when o.order_status = 'done' then 1 end) as count_order_done,
		-- количество завершенных заказов за месяц
		COUNT(case when o.order_status != 'done' then 1 end) as count_order_not_done,
		-- количество незавершенных заказов за месяц
		TO_CHAR(DATE_TRUNC('month',
		o.order_created_date),
		'YYYY-MM') as report_period
		-- отчетный период (год и месяц)
	from
		dwh.f_orders o
	join
        dwh.d_craftsmans c on
		o.craftsman_id = c.craftsman_id
	join
        dwh.d_customers cu on
		o.customer_id = cu.customer_id
	join
        dwh.d_products p on
		o.product_id = p.product_id
	group by
		c.craftsman_id,
		c.craftsman_name,
		c.craftsman_address,
		c.craftsman_birthday,
		c.craftsman_email,
		DATE_TRUNC('month',
		o.order_created_date)

) as source
on
	(
    target.craftsman_id = source.craftsman_id
		and target.report_period = source.report_period
)
	when matched then
    update
set
	craftsman_name = source.craftsman_name,
	craftsman_address = source.craftsman_address,
	craftsman_birthday = source.craftsman_birthday,
	craftsman_email = source.craftsman_email,
	craftsman_money = source.craftsman_money,
	platform_money = source.platform_money,
	count_order = source.count_order,
	avg_price_order = source.avg_price_order,
	avg_age_customer = source.avg_age_customer,
	median_time_order_completed = source.median_time_order_completed,
	top_product_category = source.top_product_category,
	count_order_created = source.count_order_created,
	count_order_in_progress = source.count_order_in_progress,
	count_order_delivery = source.count_order_delivery,
	count_order_done = source.count_order_done,
	count_order_not_done = source.count_order_not_done
	when not matched then
    insert
	(
        craftsman_id,
	craftsman_name,
	craftsman_address,
	craftsman_birthday,
	craftsman_email,
	craftsman_money,
	platform_money,
	count_order,
	avg_price_order,
	avg_age_customer,
	median_time_order_completed,
	top_product_category,
	count_order_created,
	count_order_in_progress,
	count_order_delivery,
	count_order_done,
	count_order_not_done,
	report_period
    )
values (
        source.craftsman_id,
        source.craftsman_name,
        source.craftsman_address,
        source.craftsman_birthday,
        source.craftsman_email,
        source.craftsman_money,
        source.platform_money,
        source.count_order,
        source.avg_price_order,  
        source.avg_age_customer,
        source.median_time_order_completed,
        source.top_product_category,
        source.count_order_created,
        source.count_order_in_progress,
        source.count_order_delivery,
        source.count_order_done,
        source.count_order_not_done,
		source.report_period 
    );  
insert into dwh.load_dates_craftsman_report_datamart (load_dttm) values (CURRENT_TIMESTAMP)