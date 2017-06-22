create or replace function task_manager.update_initial_task_status(_task_id int)
RETURNS text
 LANGUAGE plpgsql
AS $function$
declare
	_task_status text;
begin
 	_task_status = (select new_original_task_status from  task_manager.possible_responses where id = (select possible_response_id from task_manager.task_responses where task_id =_task_id ));
	update task_manager.tasks set task_status = _task_status  
	where id = task_manager.get_task_parent(_task_id);
	return _task_status;
end;
$function$;