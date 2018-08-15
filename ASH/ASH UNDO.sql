select
 ash.sample_time, ash.inst_id, ash.session_id, ash.session_serial#, u.username 
from
 gv$active_session_history ash,
 dba_data_files df,
 dba_tablespaces ts,
 dba_users u
where
 ash.sample_time > sysdate - 10/24/60
 and ash.current_file# = df.file_id
 and df.tablespace_name = ts.tablespace_name
 and ts.contents = 'UNDO'
 and u.user_id (+) = ash.user_id
order by ash.sample_time

--select * from dba_data_files
--select * from dba_tablespaces
