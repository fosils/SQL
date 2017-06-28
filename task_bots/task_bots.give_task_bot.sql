insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(502,'task_check_period_days','int');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(502,'target_task_type_id','int');
insert into task_manager.task_parameters (task_type_id,parameter_name,data_type) values(502,'worker_initials','text');

insert into task_bots.bots()
insert into task_manager.freelancers (worker_initials, first_name,email) values ('give_task_bot','give_task_bot','a@a.com')



select * from task_manager.freelancers
insert into task_bots.bots ("name", "type","path",task_type_id)values ('give_task_bot',1,'task_bots.give_task_bot',502)
set session.username = 'alexey'
insert into task_manager.tasks (worker_initials,parameters,task_type_id) values ('give_task_bot','{"task_check_period_days": "2", "task_type_id": "777","worker_initials":"alexey" }',777)
select * from task_manager.tasks order by id desc limit 10
select currval('tasks_id_seq')

select * from task_bots.logs
select * from task_bots.bots
select task_bots.give_task_bot(13586)
select * from task_bots.logs
select * from task_bots.schedule
delete from task_bots.schedule where id =2

select * from task_manager.tasks order by id desc limit 10

update task_bots.schedule set schedule_datetime = '2017-06-21 5:33:00' where id =3

--delete from task_bots.logs
select parameters,parameters->>'worker_initials' from task_manager.tasks where id = 13526;
select * from task_manager.tasks order by id desc limit 10

--select string_agg(parameter_name,',') from task_manager.task_parameters where task_type_id = (select task_type_id from task_bots.bots where id=(select id from task_bots.bots where name = 'give_task_bot') );
select current_timestamp
2017-06-20 13:54:47


CREATE OR REPLACE FUNCTION task_bots.give_task_bot(task_id int)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
	bot_name text = 'give_task_bot';
	sqlstr text;
	task_check_period_days int;
	task_type_id int;
	created_task_id int;
	worker_initials text;
	_parameters json;
	_parameter_name text;
	begin
		select string_agg(parameter_name,',') into _parameter_name from task_manager.task_parameters where task_manager.task_parameters.task_type_id = 502;	
		select parameters into _parameters from task_manager.tasks where id = task_id;
		task_check_period_days=_parameters->>'task_check_period_days';
		task_type_id =_parameters->>'task_type_id';
		worker_initials =_parameters->>'worker_initials';
		insert into task_manager.tasks(worker_initials ,
										until_date,
										task_type_id) 
										values (worker_initials::varchar,
										(CURRENT_TIMESTAMP AT TIME ZONE 'UTC'+ interval '1' day * task_check_period_days)::date,777
										);
										
--		perform task_manager.create_task(the_worker_initials := worker_initials::varchar,
--										task_description_variables :=null::hstore,
--										cell_table :=null, 
--										cell_column :=null, 
--										cell_id :=null, 
--										ultradox :=null, 
--										_send_from :=null, 
--										from_date :=null, 
--										until_date:=(CURRENT_TIMESTAMP AT TIME ZONE 'UTC'+ interval '1' day * task_check_period_days)::date,
--										task_type_id:=777);
		select currval('tasks_id_seq') into created_task_id ;
		insert into task_bots.schedule (action_parameters, schedule_datetime, task_id ) values(null, (CURRENT_TIMESTAMP AT TIME ZONE 'UTC'+ interval '1' day * task_check_period_days)::timestamp , created_task_id);
		insert into task_bots.logs(botname,"action","result") values (bot_name,'CREATE TASK FOR USER '||worker_initials||' task id ='||cast(created_task_id  as text)||' '||cast(task_check_period_days as text),'success');
		
		update task_manager.tasks set task_status='completed' where id = task_id;
		
		return true;
	exception when others then
		insert into task_bots.logs(botname,"action","result") values (bot_name,SQLERRM,'failed');
		update task_manager.tasks set task_status='completed_failure' where id = task_id;
		return false;
	end;
$function$;

select CURRENT_TIMESTAMP ,now()
select * from task_manager.freelancer_roles
select * from task_bots.schedule where (schedule_datetime <(CURRENT_TIMESTAMP AT TIME ZONE 'UTC') ) and completed is null
select * from task_bots.schedule where (schedule_datetime <(CURRENT_TIMESTAMP ) ) and completed is null



SELECT now() AT TIME ZONE current_setting('TimeZone');
SELECT now() AT TIME ZONE 'Europe/Paris';
SELECT now() AT TIME ZONE 'UTC';
