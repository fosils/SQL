-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--GIVE TASK AND WAIT X DAYS
--PREPARATIONS 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into task_manager.task_types (id, "name") values (1004, 'give_task_and_wait');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1004, 'worker_initials','text');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1004, 'interval_name','text');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1004, 'interval','int');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1004, 'task_type','int');

insert into task_manager.freelancers (worker_initials) values ('give_task_and_wait');
insert into task_bots.bots ("name", "type","path",task_type_id) values('give_task_and_wait',1,'task_bots.give_task_and_wait',1004);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOT FUNCTION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION task_bots.give_task_and_wait(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
 _worker_initials text;
 _task_worker_initials text;
 _interval_name text;
 _interval int;
 _task_type int;

begin
		select parameters->>'worker_initials',
			   parameters->>'interval_name',
			   parameters->>'interval',
			   parameters->>'task_type',
			   worker_initials 
		into
			   _task_worker_initials,
			   _interval_name,
			   _interval,
			   _task_type,
			   ,_worker_initials  from task_manager.tasks where id  = task_id;
			   
		--select parameters->>'customer_id' into _customer_id from task_manager.tasks where id  = task_id;
			
			insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Created task for '||cast(_task_worker_initials as text)||' task '||cast(task_id as text),'success');
			update task_manager.tasks set task_status='completed' where id = task_id;
			return true;
exception when others then
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Created task for '||cast(_task_worker_initials as text)||' task '||cast(task_id as text)||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;	
end;
$function$;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TEST INSERT TASK ()
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--insert into task_manager.tasks("name",worker_initials,task_type_id,parameters) values('Add secondary email' ,'add_customer_secondary_email',1003, '{"customer_id":"114056","email":"a@a.com"}'::jsonb);