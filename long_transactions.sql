select * from
(
select
 t.start_date,
 round((sysdate-t.start_date)*24, 2) dur_h,
 t.used_ublk, t.used_urec,
 s.status,
 s.username,
 s.osuser,
 s.machine,
 s.terminal,
 s.program,
 s.module,
 s.action,
 s.client_info,
 s.client_identifier,
 s.sql_id,
 s.prev_sql_id,
 s.event,
 s.wait_time_micro
from
 gv$transaction t, gv$session s
where
 s.inst_id = t.inst_id and s.taddr = t.addr
order by
 t.start_date
) where rownum <= 10
--select * from gv$sql where sql_id = '9m7787camwh4m'
