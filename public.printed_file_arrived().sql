CREATE OR REPLACE FUNCTION public.printed_file_arrived()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE  
	_email_from text;_email_subject text;_email_link text; _customer_id integer; _expense integer;
    s3 text;
    uid integer;
BEGIN
  uid = NEW.id;
  IF substring(NEW.s3_path_to_original_file ,'test-images/147/') is not null THEN
  	select messages.email_from, messages.email_subject, messages.email_link, messages.customer_id, messages.expense into  
    _email_from, _email_subject,_email_link, _customer_id, _expense
    from gyb_emails.messages where messages.message_uid = (substring(regexp_replace(replace(NEW.s3_path_to_original_file, 'Microsoft_Word_-_', ''),'^.+[/\\]', '') from  0 for 17));
		
		update gyb_emails.attachments set attachment_printed = 'PRINTED', receipt_id = NEW.id
			where attachment_path like '%'|| substring( regexp_replace(replace(NEW.text, 'Microsoft_Word_-_', ''),'^.+[/\\]', '') from 0 for 22)||'%';
    
    if (_customer_id is not null) THEN
			update receipts 
				set customer_id = _customer_id, expense = _expense,
					text = concat_ws(E'\n',regexp_replace(NEW.s3_path_to_original_file,'^.+[/\\]', '') ,' ',  _email_subject ,' ',_email_link)
				where id = uid;
		END IF;
  END IF;
  RETURN NEW;
END;
$function$
