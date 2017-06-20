CREATE TABLE task_bots.schedule(
	id serial,
	created timestamp NULL DEFAULT now(),
	action_parameters hstore NULL,
	completed timestamp NULL,
	failed bool NOT NULL DEFAULT false,
	schedule_datetime timestamp NULL,
	task_id int4 NULL
)
WITH (
	OIDS=FALSE
) ;
