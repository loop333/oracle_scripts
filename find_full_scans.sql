select
 u.name,
 o.object_type||' '||o.owner||'.'||o.object_name||'.'||o.subobject_name,
 a.sql_id,
 s.sql_text,
 a.cnt_waited,
 time_waited
from
(
select
 user_id, sql_id, current_obj#, count(*) cnt_waited, sum(time_waited) time_waited
from
 gv$active_session_history ash
where
 ash.sample_time > sysdate - 1/24/60 and ash.event = 'db file scattered read'
group by
 user_id, sql_id, current_obj#
) a
left outer join sys.user$ u on u.user# = a.user_id
left outer join dba_objects o on o.object_id = a.current_obj#
left outer join gv$sql s on s.sql_id = a.sql_id
order by time_waited desc

