CREATE OR REPLACE FUNCTION gyb_emails.get_s3_file_path(file_path text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
begin
	return  'https://get-file.herokuapp.com/index.php?bucket=revisor1-attachments&name='||regexp_replace(file_path,'^.+[/\\]', '');
end 
$function$