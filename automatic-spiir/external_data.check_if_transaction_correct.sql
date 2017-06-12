CREATE OR REPLACE FUNCTION external_data.check_if_transaction_correct(_transaction_id bigint)
 RETURNS bool
 LANGUAGE plpgsql
AS $function$
declare
 last_balance float;
 current_balance float;
 _amount float;
begin
	select replace(balance,',','.')::float into current_balance from external_data.spiir_raw_data where transaction_id::bigint = (_transaction_id);
	select replace(balance,',','.')::float into last_balance from external_data.spiir_raw_data where transaction_id::bigint = (_transaction_id-1);
	select replace(amount,',','.')::float into _amount from external_data.spiir_raw_data where transaction_id::bigint = (_transaction_id);
	if current_balance = (last_balance+_amount) then
		return true;
	else 
		return false;
	end if;
end;
$function$;
