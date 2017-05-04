--drop FUNCTION task_bots.insert_bot(tablename text, columns text, column_values text);
CREATE OR REPLACE FUNCTION task_bots.insert_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	tablename text;
	column_names text;
	column_values text;
	_parameters json;
	_parameter_name text;
	begin
		select string_agg(parameter_name,',') into _parameter_name from task_manager.task_parameters where task_type_id = (select task_type_id from task_bots.bots where id=1 );	
		select parameters into _parameters from task_manager.tasks where id = task_id;
		tablename=_parameters->>'tablename';
		column_names =_parameters->>'column_names';
		column_values =_parameters->>'column_values';		
		sqlstr='insert into '||tablename||' ('||column_names||') values('||column_values||')';
		--insert into task_bots.logs(botname,"action","result") values ('insert_bot',_parameters,'success');
		--insert into task_bots.logs(botname,"action","result") values ('insert_bot',sqlstr,'success');
		execute( sqlstr);	
		insert into task_bots.logs(botname,"action","result") values ('insert_bot',sqlstr,'success');
		update task_manager.tasks set task_status='completed' where id = task_id;
		return true;
	exception when others then
		insert into task_bots.logs(botname,"action","result") values ('insert_bot',SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;
