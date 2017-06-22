CREATE OR REPLACE FUNCTION task_manager.update_initial_task_status_based_on_response()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	perform task_manager.update_initial_task_status(new.task_id);
	return new;
end
$function$;

create trigger response_add_or_update after insert or update
        on
        task_manager.task_responses for each row
         execute procedure task_manager.update_initial_task_status_based_on_response();
