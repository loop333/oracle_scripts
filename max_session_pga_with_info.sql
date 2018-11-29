select
 used_ublk cnt,
 'UNDO=' || used_ublk || ' ' || username || '/' || program || '/' ||
 owner || '.' || object_name || '.' || procedure_name info
from
(
select
 t.used_ublk, s.username, s.program, p.owner, p.object_name, p.procedure_name
from
 gv$transaction t, gv$session s, dba_procedures p
where
 t.addr = s.taddr
 and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id
order by
 t.used_ublk desc
)
where
 rownum = 1

select
 max(value)
from
 gv$sesstat ss
where
 ss.statistic# = 25


select
 *
from
 gv$sesstat ss, gv$session s, dba_procedures p, gv$px_session ps
where
 ss.statistic# = 25
 and ps.inst_id (+) = ss.inst_id and ps.sid (+) = ss.sid
 and s.inst_id = ss.inst_id and s.sid = ss.sid
 and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id
order by value desc

select * from gv$px_session


select ss.value cnt, 'PGA='||ss.value||' '||s.username||'/'||s.program||'/'||p.owner||'.'||p.object_name||'.'||p.procedure_name
from gv$sesstat ss, gv$px_session ps, gv$session s, dba_procedures p
where ss.statistic# = 25 and ss.value = (select max(value) from gv$sesstat where statistic# = 25)
and ps.inst_id (+) = ss.inst_id and ps.sid (+) = ss.sid
and s.inst_id = nvl(ps.inst_id,ss.inst_id) and s.sid = nvl(ps.qcsid,ss.sid)
and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id

select
 ss.value cnt,
 'PGA='||ss.value||nvl2(ps.inst_id,' QC ',' ')||s.username||'/'||s.program||'/'||p.owner||'.'||p.object_name||'.'||p.procedure_name info
from
 gv$sesstat ss, gv$px_session ps, gv$session s, dba_procedures p
where
 ss.statistic# = 25 and ss.value = (select max(value) from gv$sesstat where statistic# = 25)
 and ps.inst_id (+) = ss.inst_id and ps.sid (+) = ss.sid
 and s.inst_id = nvl(ps.inst_id,ss.inst_id) and s.sid = nvl(ps.qcsid,ss.sid)
 and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id

