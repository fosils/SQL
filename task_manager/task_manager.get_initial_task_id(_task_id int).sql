create or replace function task_manager.get_initial_task_id(_task_id int)
RETURNS int
 LANGUAGE plpgsql
AS $function$
declare
	parent_task_id int :=_task_id;
	new_parent_task_id int;
    last_parent_task_id int;
begin
 	WHILE ( parent_task_id IS NOT NULL ) LOOP
        SELECT spawned_from_task_id into new_parent_task_id FROM task_manager.tasks WHERE id =parent_task_id;
        --raise notice '%',new_parent_task_id;
        if (new_parent_task_id is null ) then 
        	last_parent_task_id =parent_task_id;
        	end if;
        parent_task_id = new_parent_task_id;        
    END LOOP;
    RETURN last_parent_task_id;	
end;
$function$;