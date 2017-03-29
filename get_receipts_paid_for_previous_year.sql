CREATE OR REPLACE FUNCTION public.get_receipts_paid_for_previous_year(customer_id_parameter integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
  ret int;
	package_count int;
	error_num int;
	items RECORD;
BEGIN
with tmp_receipts_paid_for as( 
	select service_from as from_date, service_until as until_date, receipts_paid_for from customer_payments 
		where payment_date is not null 
		and (service_from is null or service_from < get_start_date_of_current_financial_year(customer_id_parameter) - interval '1 day') 
		and (service_until is null or service_until >= get_start_date_of_current_financial_year(customer_id_parameter) - interval '1 day') 
		and customer_id = customer_id_parameter 
) 
,error_num as (select count(*) as num  
	from (
		select 
			case 
				when (from_date is null and until_date is not null) or (from_date is not null and until_date is null) or (from_date > until_date) then true 
				else false 
			end as error from tmp_receipts_paid_for) as error_sub 
			where error = true)
,package_count as (
	select count(*) p_count  from tmp_receipts_paid_for where receipts_paid_for is not null
	)
select 
 case 
 	when (select num from error_num)>0 then concat('Error. "From" or "until" dates of one paymment are empty, or from date is higher than until date. A service package cannot end before it started. Customer_id: ', customer_id_parameter) 
 	when (select p_count from package_count)<1 then null
 	else (select sum(receipts_paid_for)::text from tmp_receipts_paid_for where receipts_paid_for is not null)
 end 
 into ret; 
return ret;
end;
$function$;

select * from get_receipts_paid_for_previous_year(114406);
select * from get_receipts_paid_for_previous_year(114408);
