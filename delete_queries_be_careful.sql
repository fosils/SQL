drop VIEW gui.delete_queries_be_careful cascade;

CREATE OR REPLACE VIEW gui.delete_queries_be_careful AS
 select
    pg_stat_activity.pid as id,
 	pg_stat_activity.query,
    date_trunc('seconds'::text, now() - pg_stat_activity.query_start)::character varying AS time_since_start,
    pg_stat_activity.usename,
    pg_stat_activity.query_start,
    pg_stat_activity.waiting,
    false as delete_query
   FROM pg_stat_activity
  WHERE pg_stat_activity.state = 'active'::text AND pg_stat_activity.query <> 'SELECT * FROM gui.running_queries'::text
  ORDER BY pg_stat_activity.query_start;
  

CREATE OR REPLACE rule edit_delete_queries_be_careful AS
on update to gui.delete_queries_be_careful
do instead
select 
case when (get_current_user()='' or get_current_user() = '') then
	CASE 
		WHEN new.delete_query=true THEN (SELECT pg_cancel_backend(new.id))
	end
end;


