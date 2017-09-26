CREATE TABLE task_bots.execute_python (
	id serial,
	python_script varchar(4000) NULL,
	parameters varchar(4000) NULL,
	schedule_time timestamp NULL,
	completed bool NULL
)
WITH (
	OIDS=FALSE
) ;
