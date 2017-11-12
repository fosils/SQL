drop table gyb_emails.auto_printing_status

create table gyb_emails.auto_printing_status
(id serial,
last_print_time timestamp,
last_email_processing_time timestamp,
today_documents_printed int,
today_emails_processed int,
today_date date,
today_runs int
);

select gyb_emails.add_today_run()
select * from gyb_emails.auto_printing_status 

drop function gyb_emails.add_today_run();

create function gyb_emails.add_today_run() 
RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	_date timestamp;
	_id int;
begin
	select id , today_date into _id ,_date from gyb_emails.auto_printing_status;
	if _id is null then insert into gyb_emails.auto_printing_status(id) values (1);
		_id =1;
	end if;
	if (date_part('day', _date) = date_part('day', current_timestamp)) then
	  update gyb_emails.auto_printing_status set  today_runs =today_runs+1 , last_email_processing_time =current_timestamp where id = _id;
	 else
	  update gyb_emails.auto_printing_status 
	  			set  	today_runs =1 , 
	  					today_date = current_timestamp , 
	  					today_documents_printed = 0 , 
	  					today_emails_processed = 0,
	  					last_email_processing_time = null , 
	  					last_print_time = null
	  	where id = _id;
	end if;
end; 
$function$

select gyb_emails.add_today_print();

drop function gyb_emails.add_today_print()

create function gyb_emails.add_today_print() 
RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	_date timestamp;
	_id int;
	_today_documents_printed int;
begin
	
	select id , today_date, today_documents_printed into _id ,_date,_today_documents_printed from gyb_emails.auto_printing_status;
	if _today_documents_printed is null then _today_documents_printed =0; end if;
	_today_documents_printed=_today_documents_printed+1;
	update gyb_emails.auto_printing_status set  today_documents_printed =_today_documents_printed, last_print_time = current_timestamp where id = _id;
end; 
$function$
