create or replace function task_manager.get_task_parent(task_id int)
RETURNS int
 LANGUAGE plpgsql
AS $function$
declare
	parent_task_id int :=task_id;
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
end
$function$;


select * from task_bots.logs
select * from pg_stat_activity where state = 'active';
select pg_cancel_backend(30085)
select task_manager.get_task_parent(13223)
select spawned_from_task_id from task_manager.tasks where id =13223
select spawned_from_task_id from task_manager.tasks where id =13222
select spawned_from_task_id from task_manager.tasks where id =13221
select spawned_from_task_id from task_manager.tasks where id =13219
select spawned_from_task_id from task_manager.tasks where id =13218
select spawned_from_task_id from task_manager.tasks where id =13217


SELECT array_prepend(1, ARRAY[2,3])
