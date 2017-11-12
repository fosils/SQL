
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--PREPARATIONS 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into task_manager.task_types (id, "name") values (1003, 'add_customer_secondary_email');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1003, 'customer_id','int');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(1003, 'email','text');
insert into task_manager.freelancers (worker_initials) values ('add_customer_secondary_email');
insert into task_bots.bots ("name", "type","path",task_type_id) values('add_customer_secondary_email',1,'task_bots.add_customer_secondary_email',1003);

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--BOT FUNCTION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION task_bots.add_customer_secondary_email(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
 _customer_id int;
 _email text;
 _customer_exists boolean;
 _worker_initials text;
begin
		select parameters->>'customer_id',parameters->>'email', worker_initials into _customer_id, _email,_worker_initials  from task_manager.tasks where id  = task_id;			
		--select parameters->>'customer_id' into _customer_id from task_manager.tasks where id  = task_id;
		select count(id)>0 into _customer_exists from public.customers where id= _customer_id;
		if _customer_exists then
			insert into public.email_addresses (customer_id, email) values (_customer_id, _email);
			insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Inserted email '||cast(_email as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text),'success');
			update task_manager.tasks set task_status='completed' where id = task_id;
			return true;
		else raise exception 'Customer does not exists !';
		end if;
exception when others then
		insert into task_bots.logs(botname,"action","result") values (_worker_initials,'Inserted email '||cast(_email as text)||' for customer '||cast(_customer_id as text)||' task '||cast(task_id as text)||' ERROR:'||SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;	
end;
$function$;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--TEST INSERT TASK ()
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
--insert into task_manager.tasks("name",worker_initials,task_type_id,parameters) values('Add secondary email' ,'add_customer_secondary_email',1003, '{"customer_id":"114056","email":"a@a.com"}'::jsonb);