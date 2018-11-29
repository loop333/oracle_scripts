--select * from dba_scheduler_jobs
--select * from dba_scheduler_running_jobs
--select * from sys.scheduler$_job

select
 sj.program_action,
 sj.schedule_expr,
 sj.comments,
 sj.running_instance,
 p.inst_id,
 p.spid,
 p.program
from
 gv$lock l, sys.scheduler$_job sj, gv$session s, gv$process p
where
 l.type = 'JS'
 and sj.obj# = l.id1
 and s.inst_id = l.inst_id and s.sid = l.sid
 and p.inst_id = l.inst_id and p.addr = s.paddr
