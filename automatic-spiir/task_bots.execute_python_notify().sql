CREATE OR REPLACE FUNCTION task_bots.execute_python_notify()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE 
        data json;
	begin
		data = row_to_json(NEW);
	    PERFORM pg_notify('bot_scheduler',data::text);
		return new;
	end;
$function$;

create trigger execute_python_notify_trigger after insert
        on
        execute_python for each row
         execute procedure execute_python_notify();