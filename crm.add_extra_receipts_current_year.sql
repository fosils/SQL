CREATE OR REPLACE FUNCTION crm.add_extra_receipts_current_year(
    _customer_id integer)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100.0
    VOLATILE NOT LEAKPROOF 
AS $function$
declare
    _price_for_extra_receipts_current_year numeric(20,2);
    _extra_receipts numeric(20,2);
    _price_for_package numeric(20,2);
    _receipts_current_year_excluding_deleted numeric(20,2);
    _service_from date;
    _service_until date;
begin     
    SELECT
        get_price_for_extra_receipts_current_year,
		extra_receipts,
        get_price_for_package ('Plus',(select * from get_receipts_paid_for_current_year (_customer_id))),
        receipts_current_year_excluding_deleted
    into 
        _price_for_extra_receipts_current_year,
        _extra_receipts,
        _price_for_package,
        _receipts_current_year_excluding_deleted
     FROM
     (
        SELECT
         customer_id,
         receipts_current_year_excluding_deleted,
            get_price_for_extra_receipts (
                receipts_current_year_excluding_deleted - get_receipts_paid_for_current_year (customer_id),
                1200,
                15
            ) AS get_price_for_extra_receipts_current_year,
            receipts_current_year_excluding_deleted - get_receipts_paid_for_current_year (customer_id) AS extra_receipts
            
        FROM
            receipts_per_customer
    ) AS egg
    WHERE customer_id = _customer_id
    ORDER BY get_price_for_extra_receipts_current_year;
    
    _service_from = (select get_start_date_of_current_financial_year(_customer_id));
    _service_until = (_service_from + interval '1 year'- interval '1 day');
    
    raise notice 'extra receipts count = %',_extra_receipts;
    raise notice '%',_price_for_extra_receipts_current_year;
    
    if (_price_for_extra_receipts_current_year>0) and 
    	(not EXISTS (SELECT * FROM customer_payments  WHERE customer_id = _customer_id and  service_from = _service_from and service_until=_service_until and package='Extra receipts')) 
    then
        insert into customer_payments(customer_id, service_from, service_until,package,receipts_paid_for , price,payment_freqency) 
            values (_customer_id , 
                _service_from,
                _service_until,
                'Extra receipts',
                (select ceil((_extra_receipts - 15)::numeric / 100) * 100),
                _price_for_extra_receipts_current_year,
								'yearly');
    end if;
end;
$function$;