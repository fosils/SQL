create or replace function gyb_emails.check_if_big_pdf_file_arrived()
	returns trigger
 	LANGUAGE plpgsql
AS $function$
declare
	_file_path text;
	_page_count int;
	_message_uid text;
	_customer_id int;
	_js text[];
	_f_pdf boolean;
	_email_to text;
	_address_in_table int;
begin	
	raise notice 'START check_if_big_pdf_file_arrived';	
 
	select new.attachment_path, new.message_uid, new.page_count  into _file_path, _message_uid, _page_count;
	_file_path = gyb_emails.get_s3_file_path(_file_path);
	raise notice 'file_path = %',_file_path;
	_f_pdf = _file_path like '%.pdf';
	raise notice 'file_path_pdf = %',_f_pdf;
	if  _f_pdf = true then
		raise notice 'file_path_pdf ';
		raise notice 'page_count = %',_page_count;
		if _page_count is null then 
			_page_count =0; 
		end if;
		if _page_count >10 then
			select email_to into _email_to from gyb_emails.messages where message_uid = _message_uid;
			//check email was sent to an address where we should "auto-print" receipts from
			select count(*) into _address_in_table from gyb_emails.email_addresses_to_process where address = _email_to;
			raise notice '_address = %',_email_to;
			raise notice '_address_in_table = %',_address_in_table;
			if _address_in_table>0 then
					raise notice 'page_count = %',_page_count;
					_js = array[_file_path,_message_uid];
					raise notice 'json = %',_js;				
					perform task_bots.create_task (1003, _js);
					new.attachment_printed = 'TOO MANY PAGES IN PDF FILE NEED TO PROCESS MANUALLY';
			else 
				raise notice 'Email_to address is not in address list';
			end if;
		end if;
	end if;
	raise notice 'END check_if_big_pdf_file_arrived';	
	return new;
end;
$function$;

select 'https://get-file.herokuapp.com/index.php?bucket=revisor1-attachments&name=15fe820a37b155a0_003-1.pdf' like '%.pdf'

create trigger check_if_big_pdf_file_arrived BEFORE INSERT OR UPDATE
        on gyb_emails.attachments
         for each row
         execute procedure check_if_big_pdf_file_arrived();

