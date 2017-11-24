create or replace function gyb_emails.check_if_csv_file_arrived()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_file_path text;
	_message_uid text;
	_customer_id int;
	_js text[];
	_f_csv boolean;
begin	
	raise notice 'START check_if_csv_file_arrived';
	select new.attachment_path , new.message_uid into _file_path, _message_uid;
	_file_path = gyb_emails.get_s3_file_path(_file_path);
	raise notice 'file_path = %',_file_path;
	_f_csv = _file_path like '%.csv';
	raise notice 'file_path_csv = %',_f_csv;
	if  _f_csv = 't' then
		raise notice 'file_path_csv ';
		select customer_id from gyb_emails.messages into _customer_id where message_uid = _message_uid and email_to = 'bank@revisor1.dk';
		if _customer_id is not null then			
			raise notice 'customer_id = %',_customer_id;
			_js = array[cast(_customer_id as text),_file_path];
			raise notice 'json = %',_js;
			perform task_bots.create_task (91, _js);
			new.attachment_printed = 'passed to import_csv_file task';
		end if;
	end if;
	raise notice 'END check_if_csv_file_arrived';
	return new;
end;
$function$;


create trigger check_if_csv_file_arrived BEFORE INSERT OR UPDATE
        on gyb_emails.attachments
         for each row
         execute procedure check_if_csv_file_arrived();         
