CREATE OR REPLACE FUNCTION cron.every_minute()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
	--PERFORM pg_notify('bot_manager','');
end;
$function$;