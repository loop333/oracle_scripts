select
-- lo.os_user_name "OS User",
 lo.oracle_username "DB User", 
-- o.owner "Schema",
-- s.machine,
-- s.terminal,
 s.program,
-- s.module,
 p.owner || '.' || p.object_name || '.' || p.procedure_name,
 o.object_name "Object", 
 o.object_type "Type", 
 rbs.segment_name "RBS",
 t.XIDUSN, t.XIDSLOT, 
 t.used_ublk "# of Blocks" 
from
 gv$locked_object lo,
 dba_objects o,
 dba_rollback_segs rbs,
 gv$transaction t,
 gv$session s, 
 dba_procedures p
where
 lo.object_id = o.object_id 
 and lo.xidusn = rbs.segment_id 
 and lo.xidusn = t.xidusn 
 and lo.xidslot = t.xidslot 
 and t.addr = s.taddr 
 and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id
order by 
 t.used_ublk desc

--select * from gv$locked_object
--select * from dba_rollback_segs
--select * from gv$transaction
