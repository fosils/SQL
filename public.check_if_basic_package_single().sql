create or replace function public.check_if_basic_package_single()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_service_from date;
	_package text;
	_current_package_count int;
	_customer_id int;
begin
	select new.customer_id, new.service_from, new.package into _customer_id,_service_from,_package;
	if ((select extra_service from products where short_name=_package)=false) then 
		select count(package)  into _current_package_count from customer_payments 
 		join products on (products.short_name = package )
 		where customer_payments.customer_id = _customer_id
			and ( _service_from between service_from and service_until)    
			and products.extra_service = false;	
		raise notice '%',_current_package_count;
		if (_current_package_count>0 ) then 
			RAISE EXCEPTION 'There is already a basic package in this period.';
		end if;
	end if ;
	return new;
end;
$function$;


create trigger check_task_for_bot_insert BEFORE INSERT OR UPDATE
        on
        customer_payments for each row
         execute procedure check_if_basic_package_single();

         
         
select * from customer_payments where customer_id = 206

insert into customer_payments (customer_id,service_from,service_until,package) values(206,'2018-05-02','2018-04-30' ,'Standard')


select count(package)  from customer_payments 
 		join products on (products.short_name = package )
 		where customer_payments.customer_id = 206
			and ( '2017-05-01' between service_from and service_until)    
			and products.extra_service = false;	
			
			
delete from customer_payments where id in (1595,
1596)