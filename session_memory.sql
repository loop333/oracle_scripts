select * from gv$pgastat order by inst_id, name

-- память sql
select * from gv$sql_workarea_active order by actual_mem_used desc

select * from gv$sesstat ss, gv$statname sn where ss.STATISTIC# = sn.STATISTIC# and sn.NAME = 'session uga memory'
order by ss.value desc
 
select * from gv$statname sn where upper(sn.name) like '%MEM%'

-- за все время
select * from gv$sesstat ss, gv$statname sn where ss.statistic# in (29,30,35,36,576) and sn.statistic# = ss.statistic#
order by ss.value desc

-- текущие
select
 sn.name, ss.value, s.inst_id, s.sid, s.serial#, s.username, s.osuser,
 p1.owner||'.'||p1.object_name||'.'||p1.procedure_name proc_entry,
 p2.owner||'.'||p2.object_name||'.'||p2.procedure_name proc,
 s.machine, s.terminal, s.program, s.sql_id, s.module, s.action, s.client_info, s.event
from gv$sesstat ss, gv$statname sn, gv$session s, dba_procedures p1, dba_procedures p2
where ss.statistic# in (29,35) and sn.inst_id = ss.inst_id and sn.statistic# = ss.statistic#
and s.inst_id = ss.inst_id and s.sid = ss.sid
and p1.object_id (+) = s.plsql_entry_object_id and p1.subprogram_id (+) = s.plsql_entry_subprogram_id
and p2.object_id (+) = s.plsql_object_id and p2.subprogram_id (+) = s.plsql_subprogram_id
order by ss.value desc
