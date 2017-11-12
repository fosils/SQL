CREATE OR REPLACE FUNCTION task_bots.notify_execute_python_script()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin	       	 
	
	if new.schedule_time <= now() then
		PERFORM pg_notify('execute_python_script','');
		raise notice  'Notifying %',now(); 
	end if;
	return new;
end;
$function$;

create trigger notify_execute_python_script after insert
        on
        task_bots.execute_python for each row
         execute procedure task_bots.notify_execute_python_script();
