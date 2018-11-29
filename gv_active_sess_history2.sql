select ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, o.owner, o.object_name, ash.event, sum(ash.wait_time+ash.time_waited)
from gv$active_session_history ash, dba_objects o, dba_users u, gv$sql sql, dba_procedures p
where ash.sample_time > sysdate - 1/24/60
and ash.current_obj# = o.object_id (+) and ash.user_id = u.user_id (+)
and ash.sql_id = sql.sql_id (+) and ash.sql_child_number = sql.child_number (+)
and ash.plsql_entry_object_id = p.object_id (+) and ash.plsql_entry_subprogram_id = p.subprogram_id (+)
--and u.username = 'BIS_BMN'
group by ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, o.owner, o.object_name, ash.event
order by 9 desc

-- momentary full scans
select
 s.username,
 s.program,
 p.owner, p.object_name,
 (select sql_fulltext from gv$sql where sql_id = s.sql_id and child_number = s.sql_child_number and rownum = 1) sql,
 o.owner, o.object_name
from gv$session s, dba_objects o, dba_procedures p
where s.event in ('db file scattered read','db file parallel read')
and o.object_id (+) = s.row_wait_obj#
and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id

-- full scans �� 1 ������
select username, program,
 (select sql_fulltext from gv$sql where sql_id = sql_id and child_number = sql_child_number and rownum = 1) sql,
 owner, object_name, p_owner, p_object_name
from
(
select
 distinct
 u.username,
 ash.program,
 p.owner p_owner, p.object_name p_object_name,
 ash.sql_id, ash.sql_child_number,
 o.owner, o.object_name
from gv$active_session_history ash, dba_objects o, dba_procedures p, dba_users u
where ash.sample_time > sysdate - 1/24/60
and ash.event in ('db file scattered read','db file parallel read')
and u.user_id (+) = ash.user_id
and o.object_id (+) = ash.current_obj#
and p.object_id (+) = ash.plsql_entry_object_id and p.subprogram_id (+) = ash.plsql_entry_subprogram_id
)

-- ��� �� �������� ������� ��������
select ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, o.owner, o.object_name, ash.event,
 count(*), sum(ash.wait_time+ash.time_waited), sum(ash.wait_time+ash.time_waited)/count(*)
from gv$active_session_history ash, dba_objects o, dba_users u, gv$sql sql, dba_procedures p
where ash.sample_time > sysdate - 10/24/60
and ash.current_obj# = o.object_id (+) and ash.user_id = u.user_id (+)
and ash.sql_id = sql.sql_id (+) and ash.sql_child_number = sql.child_number (+)
and ash.plsql_entry_object_id = p.object_id (+) and ash.plsql_entry_subprogram_id = p.subprogram_id (+)
group by ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, o.owner, o.object_name, ash.event
order by 11 desc

-- full scans for last 5 minuits
select
 username,
-- sql_id, sql_child_number,
 (select sql.sql_fulltext from gv$sql sql where sql.sql_id = a.sql_id and sql.child_number = a.sql_child_number and rownum < 2),
 owner, object_name, sum_time
from
(
select
 u.username,
 ash.sql_id, ash.sql_child_number,
 o.owner, o.object_name, sum(ash.time_waited+ash.wait_time) sum_time
from gv$active_session_history ash, dba_users u, dba_objects o
where ash.sample_time > sysdate - 5/24/60
and ash.event = 'db file scattered read'
and u.user_id (+) = ash.user_id
and o.object_id (+) = ash.current_obj#
group by u.username, ash.sql_id, ash.sql_child_number, o.owner, o.object_name
) a
order by sum_time desc

select
 ash2.instance_number inst,
 u.username,
 (select to_char(substr(sql_text,1,200)) from dba_hist_sqltext where sql_id = ash2.sql_id) sql,
 p.owner, p.object_name,
 o.owner, o.object_name,
 ash2.event,
 sum(ash2.wait_time+ash2.time_waited)
from dba_hist_snapshot snap, dba_hist_active_sess_history ash2, dba_objects o, dba_users u, dba_procedures p
where snap.dbid = 304481731 and snap.instance_number in (2,3)
and snap.end_interval_time >= to_date('08.06.2009 15:30:00','DD.MM.YYYY HH24:MI:SS')
and snap.begin_interval_time < to_date('08.06.2009 15:35:00','DD.MM.YYYY HH24:MI:SS')
and ash2.dbid = 304481731 and ash2.snap_id = snap.snap_id and ash2.instance_number = snap.instance_number
and ash2.sample_time >= to_date('08.06.2009 15:30:00','DD.MM.YYYY HH24:MI:SS')
and ash2.sample_time < to_date('08.06.2009 15:35:00','DD.MM.YYYY HH24:MI:SS')
and ash2.current_obj# = o.object_id (+) and ash2.user_id = u.user_id (+)
and ash2.plsql_entry_object_id = p.object_id (+) and ash2.plsql_entry_subprogram_id = p.subprogram_id (+)
group by ash2.instance_number, u.username, ash2.sql_id, p.owner, p.object_name, o.owner, o.object_name, ash2.event
order by 9 desc

select * from gv$fixed_view_definition vd where vd.VIEW_NAME = 'GV$SQLAREA'

select * from gv$database

select o.owner, o.object_name, sum(ash.wait_time+ash.time_waited)
from gv$active_session_history ash, dba_objects o
where ash.sample_time > sysdate - 10/24/60
and ash.current_obj# = o.object_id (+)
group by o.owner, o.object_name
order by 3 desc

select trunc(sample_time,'MI'), sum(wait_time+time_waited) from gv$active_session_history
where program = 'PRG_NAME' and inst_id = 2
group by trunc(sample_time,'MI')
order by 1

select * from gv$active_session_history
where program = 'PRG_NAME' and inst_id = 2 and trunc(sample_time,'MI') = to_date('26.04.2009 23:47:00','DD.MM.YYYY HH24:MI:SS')

select * from
(
select * from gv$sqlarea s order by s.elapsed_time desc
) where rownum <= 10

select trunc(ash.sample_time,'MI'), sum(ash.wait_time+ash.time_waited)
from gv$active_session_history ash, dba_objects o
where ash.current_obj# = o.object_id (+) and o.object_name = 'TABLE_NAME'
group by trunc(ash.sample_time,'MI')
order by 1

select round((cont.value/(scn.value+rid.value))*100,2)
from v$sysstat cont, v$sysstat scn, v$sysstat rid
where cont.name= 'table fetch continued row'
and scn.name= 'table scan rows gotten'
and rid.name= 'table fetch by rowid'

select owner, table_name, chain_cnt, num_rows, chain_cnt/num_rows from dba_tables where chain_cnt > 0 and num_rows > 0

select *
from gv$session sr, dba_objects o
where sr.row_wait_obj# = o.object_id (+) and o.object_name = 'TABLE_NAME'

select * from gv$active_session_history ash, dba_objects o1, dba_objects o2 where sample_time > sysdate - 1/24/60/60 and program like 'oracle%(J%)'
and o1.object_id (+) = ash.plsql_entry_object_id
and o2.object_id (+) = ash.plsql_object_id

select * from dba_procedures


select * from gv$active_session_history ash, dba_procedures p1, dba_procedures p2
where sample_time > sysdate - 1/24/60/60 and program like 'oracle%(J%)'
and p1.object_id (+) = ash.plsql_entry_object_id
and p1.subprogram_id (+) = ash.plsql_entry_subprogram_id
and p2.object_id (+) = ash.plsql_object_id
and p2.subprogram_id (+) = ash.plsql_subprogram_id

select sql_id, plsql_entry_object_id from gv$active_session_history ash where sample_time > sysdate - 10/24/60

select ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, ash.event, sum(ash.wait_time+ash.time_waited)
from gv$active_session_history ash, dba_objects o, dba_users u, gv$sqlarea sql, dba_procedures p
where ash.current_obj# = o.object_id and o.object_name = 'TABLE_NAME'
      and ash.user_id = u.user_id (+)
      and ash.sql_id = sql.sql_id (+)
      and ash.plsql_entry_object_id = p.object_id (+) and ash.plsql_entry_subprogram_id = p.subprogram_id (+)
group by ash.inst_id, u.username, sql.sql_text, p.owner, p.object_name, ash.event
order by 7 desc

select *
from gv$active_session_history ash, dba_users u
where ash.user_id = u.user_id (+) and u.username = 'OWNER' and sample_time > sysdate - 15/24/60
and sql_id is null and event is null and plsql_entry_object_id is null

select * from gv$sqlarea where object_status != 'VALID'

select * from gv$bgprocess where paddr != '00'

select * from gv$bh bh where bh.FILE# = 314 and bh.block# = 592
select * from sys.obj$ where dataobj# = 2938672

select * from gv$active_session_history where sql_id is null and current_obj# = -1 and event is null
and plsql_entry_object_id is null
and program not like '%(LMS%'
and program not like '%(LCK%'
and program not like '%(LMD%'
and program not like '%(LGWR)'
and program not like '%(CKPT)'
and program not like '%(PMON)'
and program not like '%(DBW%'
