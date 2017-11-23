drop table gyb_emails.auto_printing_status


alter table gyb_emails.auto_printing_status add column email_sent boolean; 

alter table gyb_emails.auto_printing_status add column error boolean;

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

select gyb_emails.DateDiff('hour','2017-11-14 12:50:24'::timestamp,current_timestamp::timestamp)>1

drop function gyb_emails.add_today_run();

create or replace function gyb_emails.add_today_run() 
RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	_date timestamp;
	_id int;
begin
	select id , today_date into _id ,_date from gyb_emails.auto_printing_status limit 1;
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

create or replace function gyb_emails.add_today_print() 
RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	_date timestamp;
	_id int;
	_today_documents_printed int;
begin	
	select id , today_date, today_documents_printed into _id ,_date,_today_documents_printed from gyb_emails.auto_printing_status limit 1;
	if _today_documents_printed is null then _today_documents_printed =0; end if;
	_today_documents_printed=_today_documents_printed+1;
	update gyb_emails.auto_printing_status set  today_documents_printed =_today_documents_printed, last_print_time = current_timestamp where id = _id;
end; 
$function$

CREATE OR REPLACE FUNCTION gyb_emails.datediff (units VARCHAR(30), start_t TIMESTAMP , end_t TIMESTAMP ) 
     RETURNS INT AS $$
   DECLARE
     diff_interval INTERVAL; 
     diff INT = 0;
     years_diff INT = 0;
   BEGIN
     IF units IN ('yy', 'yyyy', 'year', 'mm', 'm', 'month') THEN
       years_diff = DATE_PART('year', end_t) - DATE_PART('year', start_t);
 
       IF units IN ('yy', 'yyyy', 'year') THEN
         -- SQL Server does not count full years passed (only difference between year parts)
         RETURN years_diff;
       ELSE
         -- If end month is less than start month it will subtracted
         RETURN years_diff * 12 + (DATE_PART('month', end_t) - DATE_PART('month', start_t)); 
       END IF;
     END IF;
 
     -- Minus operator returns interval 'DDD days HH:MI:SS'  
     diff_interval = end_t - start_t;
 
     diff = diff + DATE_PART('day', diff_interval);
 
     IF units IN ('wk', 'ww', 'week') THEN
       diff = diff/7;
       RETURN diff;
     END IF;
 
     
     
     IF units IN ('dd', 'd', 'day') THEN
       RETURN diff;
     END IF;
 
     diff = diff * 24 + DATE_PART('hour', diff_interval); 
 
     IF units IN ('hh', 'hour') THEN
        RETURN diff;
     END IF;
 
     diff = diff * 60 + DATE_PART('minute', diff_interval);
 
     IF units IN ('mi', 'n', 'minute') THEN
        RETURN diff;
     END IF;
 
     diff = diff * 60 + DATE_PART('second', diff_interval);
 
     RETURN diff;
   END;
   $$ LANGUAGE plpgsql;

select cron.every_minute()

select current_timestamp::timestamp without time zone
select  gyb_emails.check_if_printing_working() 
select * from gyb_emails.auto_printing_status
select * from gyb_emails.log
create table gyb_emails.log(
id serial,
date timestamp,
who text
)


select gyb_emails.add_today_run()

create or replace function gyb_emails.check_if_printing_working() 
RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	_last_email_processing_time timestamp;
	_id int;
	_today_documents_printed int;
	_email_sent boolean;
	_error boolean;
begin
	--insert into gyb_emails.log(date,who) values (current_timestamp,'CHECK');
	select id , last_email_processing_time, email_sent , error into _id ,_last_email_processing_time,_email_sent, _error from gyb_emails.auto_printing_status limit 1;
	raise notice 'NOW(%)',current_timestamp::timestamp with time zone;
	raise notice '   (%)',_last_email_processing_time+interval '5 hours';
	if (gyb_emails.DateDiff('hour',(_last_email_processing_time+interval '5 hours')::timestamp ,current_timestamp::timestamp )>=1) then
	raise notice 'MORE THAN 1 HOUR';
		if (_email_sent<>True)or (_email_sent is null) then
			raise notice '';
			
			insert into actions (templateurl, action_parameters) values ('http://www.ultradox.com/run/f1J6TKlG46lHEgg2YEQY3NSWWKSJh5', 
            	hstore('query_that_failed', 'AUTO-PRINTING IS NOT WORKING MORE THAN 1 HOUR') || hstore('primary_email', 'ignatyuk.a@gmail.com') || hstore('description', 'auto_printing'));
        	notify emailer;
        	update gyb_emails.auto_printing_status set error = true;
        	update gyb_emails.auto_printing_status set email_sent =true;
        end if;
    else 
	    if _error = true then
			insert into actions (templateurl, action_parameters) values ('http://www.ultradox.com/run/f1J6TKlG46lHEgg2YEQY3NSWWKSJh5', 
            	hstore('query_that_failed', 'AUTO-PRINTING STARTED WORKING') || hstore('primary_email', 'ignatyuk.a@gmail.com') || hstore('description', 'auto_printing'));
        	notify emailer;
        	update gyb_emails.auto_printing_status set error = false;
        	update gyb_emails.auto_printing_status set email_sent =false;
	    
    	end if;
	end if;
end; 
$function$



select * from gyb_emails.attachments limit 10