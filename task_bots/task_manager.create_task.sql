CREATE OR REPLACE FUNCTION task_manager.create_task(the_worker_initials character varying, task_description_variables hstore, cell_table character varying DEFAULT NULL::character varying, cell_column character varying DEFAULT NULL::character varying, cell_id character varying DEFAULT NULL::character varying, ultradox character varying DEFAULT 'http://www.ultradox.com/run/70MOlfOSvzYJRwKpruI3iLNBXpBmv3'::character varying, _send_from character varying DEFAULT 'salg@ebogholderen.dk'::character varying, from_date date DEFAULT NULL::date, until_date date DEFAULT NULL::date)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
declare 
	accept_unique_short_id text;
	reject_unique_short_id text;
	completed_unique_short_id text;
	completed_failure_unique_short_id text;
	task_unique_short_id text;
	deadline timestamp;
	task_giver varchar;
	worker_email varchar;
begin
	accept_unique_short_id = task_manager.smart_link_unique_short_id();
	reject_unique_short_id = task_manager.smart_link_unique_short_id();
	completed_unique_short_id = task_manager.smart_link_unique_short_id();
	completed_failure_unique_short_id = task_manager.smart_link_unique_short_id();
	task_unique_short_id = task_manager.task_unique_short_id();
	deadline = null;--now() + interval '3 days';
	--execute('select current_setting(''session.username'') into task_giver;');
	select email into worker_email from freelancers where freelancers.worker_initials = the_worker_initials;
	if (worker_email is null) then raise EXCEPTION 'Wrong initials or no email on freelancer. Remember small letters';
	end if;
	INSERT INTO task_manager.tasks (
		NAME,
		worker_initials,
		deadline,
		task_details,
		hash,
		ultradox_url, 
		sent, cell_table, cell_column, cell_id, from_date, until_date, task_type_id,task_giver
	)
	VALUES
		(
			cell_column, the_worker_initials, deadline,
			hstore('email_subject', 'You have been given a new task:') || hstore('sendFrom', _send_from) || hstore('mergedHtml.sendFrom', _send_from) || hstore('html.sendFrom', _send_from) || task_description_variables || hstore('deadline', deadline::text) || hstore('cell_column', cell_column) || hstore('from', "gui"."get_current_user"()) || hstore('worker_email', worker_email) || hstore('reject_link', concat('ebogholderen.dk/smart_links/smart_links.php?hash=', reject_unique_short_id)) || hstore('accept_link', concat('ebogholderen.dk/smart_links/smart_links.php?hash=', accept_unique_short_id)) || hstore('completed_link', concat('ebogholderen.dk/smart_links/smart_links.php?hash=', completed_unique_short_id)) || hstore('completed_with_failure_link', concat('ebogholderen.dk/smart_links/smart_links.php?hash=', completed_failure_unique_short_id)),
			task_unique_short_id,
			replace(ultradox, '/edit/', '/run/'),
			TRUE, cell_table, cell_column, cell_id, from_date, until_date, (select id from column_task_description where column_name = cell_column), gui.get_current_user());

	INSERT INTO smart_links (hash, redirect_url, QUERY) values 
	(accept_unique_short_id, 'http://tinyurl.com/h2hgnbl', concat('select task_manager.update_task_and_colors_from_smartlink(''', task_unique_short_id, ''', ''accepted'',''', cell_table, ''',''', cell_column, ''',''', cell_id, ''')'));
	INSERT INTO smart_links (hash, redirect_url, QUERY) values 
	(reject_unique_short_id, 'http://tinyurl.com/h2hgnbl', concat('select task_manager.update_task_and_colors_from_smartlink(''', task_unique_short_id, ''', ''rejected'',''', cell_table, ''',''', cell_column, ''',''', cell_id, ''')'));
	INSERT INTO smart_links (hash, redirect_url, QUERY) values 
	(completed_unique_short_id, 'http://tinyurl.com/h2hgnbl', concat('select task_manager.update_task_and_colors_from_smartlink(''', task_unique_short_id, ''', ''completed'',''', cell_table, ''',''', cell_column, ''',''', cell_id, ''')'));
	INSERT INTO smart_links (hash, redirect_url, QUERY) values 
	(completed_failure_unique_short_id, 'http://tinyurl.com/h2hgnbl', concat('select task_manager.update_task_and_colors_from_smartlink(''', task_unique_short_id, ''', ''completed_failure'',''', cell_table, ''',''', cell_column, ''',''', cell_id, ''')'));
end;
$function$
