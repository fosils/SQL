create or replace function task_bots.create_task_test(type_id int, text[])
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
declare
 _name text;
 _freelancer text;
 _parameters json;
 _param_names text[];
 _param_values ALIAS FOR $2;
 _str text;
 _p_v jsonb;
 i int;
 _len_param_names int;
 _len_param_values int;
begin
	
	_str = '';
	select column_name,default_freelancer into _name, _freelancer from task_manager.column_task_description where id = type_id;
	select array_agg(parameter_name::text) into _param_names  from task_manager.task_parameters where task_type_id =type_id;
	raise notice 'params_length = %',array_length(_param_names,1);
	raise notice 'values_length = %',array_length(_param_values,1);
	_len_param_names=array_length(_param_names,1) ;	
	_len_param_values=array_length(_param_values,1);
	if _len_param_names is null then _len_param_names = 0; end if;
	if _len_param_values is null then _len_param_values = 0; end if;
	
	if  _len_param_names <> _len_param_values then
	    raise exception 'parameter count mismatch must be %',array_length(_param_names,1);
	end if;
    select json_object(_param_names , _param_values) into _p_v;
	raise notice 'params = %',_param_names;
	raise notice 'params values = %',_param_values;
	raise notice '%',_str; 
    raise notice '%',_p_v;
	--insert into tasks (name,worker_initials,parameters ) values (_name, _freelancer,_p_v);
	return true;
exception when others then
	raise notice 'arrays is equal %', array_length(_param_names,1) <> array_length(_param_values,1);
	raise notice 'ERROR %' , SQLERRM;
	return false;
end
$function$