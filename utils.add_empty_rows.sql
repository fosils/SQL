CREATE OR REPLACE FUNCTION utils.add_empty_rows(table_name text, number_of_rows integer DEFAULT 50)
 RETURNS void
 LANGUAGE plpgsql
AS $function$
DECLARE
_str text;
_str2 text;
_count integer;
BEGIN
_str=$$select 'select count(*) from $$ || table_name || $$ where ' ||string_agg('("'||column_name||'" is null)' , ' and ') 
	from information_schema.columns 
	where table_name ='$$||table_name||$$' and column_default is null$$;
--raise notice 'Value: %', _str;
execute (_str ) into _str2;
--raise notice 'Value2: %', _str2;
execute ( _str2	) into _count;
--raise notice 'Count: %', _count;
if _count < number_of_rows then
	--raise notice 'Inserting Rows';
	execute (select string_agg('insert into '||table_name||' default values',';') from generate_series(1,number_of_rows - _count));
end if;
END;
$function$;