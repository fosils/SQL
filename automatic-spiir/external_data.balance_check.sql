--drop FUNCTION external_data.balance_check(_transaction_id bigint, _account_id bigint)
CREATE OR REPLACE FUNCTION external_data.balance_check(_transaction_id bigint, _account_id bigint,_date date)
 RETURNS bool
 LANGUAGE plpgsql
AS $function$
declare
 last_balance numeric;
 current_balance numeric;
 _amount numeric;
 last_transaction_id bigint;
begin
	select max(external_data.spiir_raw_data.transaction_id ::bigint) into last_transaction_id from external_data.spiir_raw_data 
		where 
			external_data.spiir_raw_data.transaction_id::bigint<_transaction_id 
			and external_data.spiir_raw_data.account_id::bigint =_account_id
			and external_data.spiir_raw_data.date::date<=_date; 
	raise notice '%',last_transaction_id;
	select replace(balance,',','.')::numeric into current_balance from external_data.spiir_raw_data where transaction_id::bigint = (_transaction_id);
	raise notice '%',current_balance;
	select replace(balance,',','.')::numeric into last_balance from external_data.spiir_raw_data where transaction_id::bigint = (last_transaction_id);
	raise notice '%',last_balance;
	select replace(amount,',','.')::numeric into _amount from external_data.spiir_raw_data where transaction_id::bigint = (_transaction_id);
	raise notice '%',_amount;
	if current_balance = (last_balance+_amount) then
		return true;
	else 
		return false;
	end if;
end;
$function$;
