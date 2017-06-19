--drop schema task_bots;
create schema task_bots;
--drop table task_bots.bots ;
CREATE TABLE task_bots.bots (
	id serial NOT NULL ,
	"name" text NULL,
	"type" int4 not null default 1,
	"path" varchar(100) NULL,
	task_type_id int,
	CONSTRAINT bots_pk PRIMARY KEY (id)
);


create table task_bots.logs(id serial, botname text, date timestamp DEFAULT now(), action text, result text,task_id int, CONSTRAINT logs_pk PRIMARY KEY (id)
);
--alter table task_bots.logs add column ;


CREATE OR REPLACE FUNCTION task_manager.check_if_task_for_bot()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE 
        data json;
        worker_initials text;
        notification json;
        bot_count int;
	begin
			data = row_to_json(NEW);
			worker_initials =data->>'worker_initials'; 
			select  count(id) as count into bot_count from task_bots.bots where name = worker_initials;
			--PERFORM pg_notify('bot_manager',worker_initials::text);
			if bot_count>0 then
	       	 PERFORM pg_notify('bot_manager',data::text);
	       	end if;
		return new;
	end;
$function$;

create trigger check_task_for_bot_insert after insert
        on
        tasks for each row
         execute procedure check_if_task_for_bot();

select * from task_bots.shedule         
create table task_bots.shedule(id serial, scheduled_date timestamp, bot_id int, task_id int, params json)
insert into task_bots.bots(name,"path","type") values ('insert_bot','task_bots.insert_bot',1);
insert into task_bots.bots(name,"path","type") values ('completed','task_bots.completed_bot',1);

insert into task_bots.bots(name,"path","type") values ('give_task_bot','task_bots.give_task_bot',3);

select pg_notify('bot_manager','');