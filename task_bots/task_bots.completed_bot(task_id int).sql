CREATE OR REPLACE FUNCTION task_bots.completed_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	sqlstr text;
	_worker_initials text;
	_task_id_to_complete int;
	_parameters json;
	begin
		select cell_id,worker_initials into _task_id_to_complete,_worker_initials from task_manager.tasks where id = task_id;
		update task_manager.tasks set task_status='completed' where id = _task_id_to_complete;
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Complete task '||cast(_task_id_to_complete as text),'success');
		update task_manager.tasks set task_status='completed' where id = task_id;
		return true;
	exception when others then
		insert into task_bots.logs(botname,"action","result") values ('insert_bot','Complete task '||cast(_task_id_to_complete as text) ||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;