CREATE OR REPLACE FUNCTION crm.automate_customers_we_need_to_invoice(
    _customer_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE NOT LEAKPROOF 
AS $function$


declare
    _price_for_extra_receipts_previous_year numeric(20,2);
    _extra_receipts numeric(20,2);
    _price_for_package numeric(20,2);
    _receipts_previous_year_excluding_deleted numeric(20,2);
    _service_from date;
    _service_until date;
    _service_from_current date;
    _service_until_current date;
begin     
	
    SELECT
        get_price_for_extra_receipts_previous_year,
				extra_receipts,
        get_price_for_package ('Plus',(select * from get_receipts_paid_for_previous_year (_customer_id))),
        receipts_previous_year_excluding_deleted
    into 
        _price_for_extra_receipts_previous_year,
        _extra_receipts,
        _price_for_package,
        _receipts_previous_year_excluding_deleted
     FROM
     (
        SELECT
         customer_id,
         receipts_previous_year_excluding_deleted,
            get_price_for_extra_receipts (
                receipts_previous_year_excluding_deleted - get_receipts_paid_for_previous_year (customer_id),
                1200,
                15
            ) AS get_price_for_extra_receipts_previous_year,
            receipts_previous_year_excluding_deleted - get_receipts_paid_for_previous_year (customer_id) AS extra_receipts
            
        FROM
            receipts_per_customer
    ) AS egg
    WHERE customer_id = _customer_id
    ORDER BY get_price_for_extra_receipts_previous_year;
    
    _service_from_current=(get_start_date_of_current_financial_year(_customer_id) - interval '1 year');
    _service_until_current= (get_start_date_of_current_financial_year(_customer_id) - interval '1 day');    
    _service_from = (_service_until_current + interval '1 day');
    _service_until = (_service_until_current + interval '1 year');
    
    if (_price_for_extra_receipts_previous_year>0) and 
    	(not EXISTS (SELECT * FROM customer_payments  WHERE customer_id = _customer_id and  service_from = _service_from_current and service_until=_service_until_current and package='Extra receipts')) then
        insert into customer_payments(customer_id, service_from, service_until,package,receipts_paid_for , price,payment_freqency) 
            values (_customer_id , 
                _service_from_current,
                _service_until_current,
                'Extra receipts',
                (select ceil((_extra_receipts - 15)::numeric / 100) * 100),
                _price_for_extra_receipts_previous_year,
								'yearly'
               );
    end if;
    
  
    CREATE TEMP TABLE temp_customer_payments AS 
        select customer_id,
						get_start_date_of_current_financial_year(_customer_id)::date as service_from,
						(get_start_date_of_current_financial_year(_customer_id) + interval '1 year'-interval '1 day')::date as service_until,
						package,
						receipts_paid_for,
						price,
						payment_freqency 
				from 
					customer_payments 
						join products on (
							products.short_name = customer_payments.package
						) 
				where 
					customer_id = _customer_id 
					and payment_freqency = 'yearly' and products.one_time_or_repetitive = 'repetitive'
					and service_from <= get_start_date_of_current_financial_year(_customer_id) - interval '1 year' 
					and service_until >= get_start_date_of_current_financial_year(_customer_id) - interval '1 day';
	
	insert into customer_payments(customer_id, service_from, service_until,package,receipts_paid_for , price, payment_freqency)
	SELECT
 		customer_id,
 		service_from,
 		service_until,
 		package,
 		TEMP_customer_payments.receipts_paid_for,
 		TEMP_customer_payments.price,
 		TEMP_customer_payments.payment_freqency
	FROM
 		customer_payments
	FULL OUTER JOIN temp_customer_payments USING (
											customer_id,
 											service_from,
 											service_until,
 											package)
	WHERE
 		customer_payments.customer_id IS null
 		and TEMP_customer_payments.customer_id = _customer_id;
				
	drop table temp_customer_payments;
end;
$function$;


--select * from crm.automate_customers_we_need_to_invoice(114189)
SELECT * FROM customer_payments  WHERE customer_id = 114189 
	and  service_from = (select max(service_from)::Date from customer_payments where customer_id = 114189 and payment_freqency = 'yearly')
	and service_until=(select max(service_until)::Date from customer_payments where customer_id = 114189 and payment_freqency = 'yearly') 
	and package='Extra receipts'

select * from customer_payments where customer_id = 114189

delete from customer_payments where id in (1033,
1032)