CREATE OR REPLACE FUNCTION task_manager.update_initial_task_status_based_on_response()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
declare 
 initial_task_id int;
begin
	initial_task_id = task_manager.get_initial_task_id(new.task_id);
	update task_manager.tasks set task_status = (select new_original_task_status from  task_manager.possible_responses where id = (select possible_response_id from task_manager.task_responses where task_id =new.task_id ))  
	where id = task_manager.get_initial_task_id(new.task_id);
	if initial_task_id <> new.task_id then
		update task_manager.tasks set task_status = 'completed' where id = new.task_id;
	end if;
	return new;
end
$function$;

create trigger update_initial_task_status_based_on_response after insert or update
        on
        task_manager.task_responses for each row
         execute procedure task_manager.update_initial_task_status_based_on_response();
