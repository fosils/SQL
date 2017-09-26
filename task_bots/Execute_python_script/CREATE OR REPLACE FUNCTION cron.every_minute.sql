CREATE OR REPLACE FUNCTION cron.every_minute()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare c int;
begin
	c = (select count(*) 
				from task_bots.execute_python 
				where schedule_time <=now() 
					and (completed = false or completed is null));
	raise notice 'Now is %',now(); 
	if c>0 then
		raise notice 'Count(%)',c;
		PERFORM pg_notify('execute_python_script','');
		raise notice 'execute_python_script';
	else 
		raise notice 'no python scripts found';
	end if;

end;
$function$;



