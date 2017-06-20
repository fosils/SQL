create or replace function public.check_if_basic_package_single()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_from_date date;
	_until_date date;
	_package text;
	_current_package_count int;
	_customer_id int;
	_date_diff int;
begin
	select new.customer_id, new.service_from, new.service_until,new.package into _customer_id,_from_date,_until_date,_package;
	if ((select extra_service from products where short_name=_package)=false) then 
		select DATE_PART('year', get_start_date_of_current_financial_year(_customer_id)::date) - DATE_PART('year', _from_date::date) into _date_diff;
 		select count(package)  into _current_package_count from customer_payments 
 		join products on (products.short_name = package )
 		where customer_payments.customer_id = _customer_id
			and service_from >= (get_start_date_of_current_financial_year(_customer_id) - interval '1 year'*_date_diff)  
			and (service_until <= get_start_date_of_current_financial_year(_customer_id)- interval '1 year'*_date_diff + interval '1 year')
			and products.extra_service = false;
	
	
		if (_current_package_count>0 ) then 
		then
			RAISE EXCEPTION 'There is already a basic package in this period';
		end if;
	end if ;
	return new;
end;
$function$;


create trigger check_task_for_bot_insert BEFORE INSERT OR UPDATE
        on
        customer_payments for each row
         execute procedure check_if_basic_package_single();
