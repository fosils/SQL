create or replace function external_data.spiir_bank_import(_customer_id int)
RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare v_cnt int;
begin
	insert into public.bank_transactions (customer_id, transaction_date,text,amount, balance,bank_account)  
	select customer_id,
		date::date,
		original_description,
		replace(amount,',','.')::numeric,
		replace(balance,',','.')::numeric,
		(
		select bank_slot from customer_bank_accounts 
			where customer_bank_accounts.customer_id = external_data.spiir_raw_data.customer_id 
			and customer_bank_accounts.spiir_name =external_data.spiir_raw_data.account_name 
			)  
	from 
		external_data.spiir_raw_data 
	where 
		customer_id = _customer_id
		and 
		(row
			(
			customer_id,"date"::date,original_description,
			replace(amount,',','.')::numeric,
			replace(balance,',','.')::numeric,
				(
				select bank_slot from customer_bank_accounts 
				where customer_bank_accounts.customer_id = external_data.spiir_raw_data.customer_id 
				and customer_bank_accounts.spiir_name =external_data.spiir_raw_data.account_name
				)
			) 
		not in ( select customer_id, transaction_date,text,amount, balance,bank_account 
				from public.bank_transactions where customer_id = _customer_id
				)
		);
		GET DIAGNOSTICS v_cnt = ROW_COUNT;
		raise notice 'Inserted % rows',v_cnt;
		return true;
	exception when others then
		raise notice '%',SQLERRM;
		return false;				
end
$function$;


