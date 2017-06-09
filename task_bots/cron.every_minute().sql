--drop function cron.every_minute()
CREATE OR REPLACE FUNCTION cron.every_minute()
 RETURNS void
 LANGUAGE plpgsql
AS $function$
begin
	--PERFORM pg_notify('bot_manager','');
end;
$function$;