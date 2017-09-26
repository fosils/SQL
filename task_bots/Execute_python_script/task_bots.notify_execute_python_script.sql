CREATE OR REPLACE FUNCTION task_bots.notify_execute_python_script()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin	       	 
	PERFORM pg_notify('execute_python_script','');
	return new;
end;
$function$;

create trigger notify_execute_python_script after insert
        on
        task_bots.execute_python for each row
         execute procedure task_bots.notify_execute_python_script();
