select * from gv$active_session_history ash, dba_objects o where ash.current_obj# = o.object_id (+)

select ash.event, o.object_name, sum(ash.wait_time+ash.time_waited) from gv$active_session_history ash, dba_objects o
where ash.sample_time > sysdate - 5/24/60 and ash.current_obj# = o.object_id (+)
group by ash.event, o.object_name
order by 3 desc

select ash.event, o.object_name, sum(ash.time_waited) from gv$active_session_history ash, dba_objects o
where ash.sample_time > sysdate - 5/24/60 and ash.current_obj# = o.object_id (+)
group by ash.event, o.object_name
order by 3 desc

