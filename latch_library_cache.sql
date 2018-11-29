/*
select * from gv$latchholder where name = 'library cache'
select * from gv$latch where name = 'library cache'
select * from gv$latchname where name = 'library cache'
select * from gv$latch_children where name = 'library cache'
select * from gv$latch_parent where name = 'library cache'
select * from gv$latch_misses where parent_name = 'library cache'
select * from dba_hist_latch
select * from dba_hist_latch_misses_summary
select * from dba_hist_latch_name
*/

select
 s.username,
 s.machine, s.terminal, s.program, s.module, s.action,
 up1.name||'.'||op1.name||'.'||p1.procedurename "Entry Proc",
 up2.name||'.'||op2.name||'.'||p2.procedurename "Procedure",
 s.event,
 s.wait_time,
 s.seconds_in_wait
from
 gv$latchholder lh,
 gv$session s,
 sys.obj$ o, sys.user$ uo,
 sys.obj$ op1, sys.user$ up1, sys.procedureinfo$ p1,
 sys.obj$ op2, sys.user$ up2, sys.procedureinfo$ p2
where
 lh.name = 'library cache'
 and s.inst_id = lh.inst_id and s.sid = lh.sid
 and o.obj# (+) = s.row_wait_obj#
 and uo.user# (+) = o.owner#
 and op1.obj# (+) = s.plsql_entry_object_id and up1.user# (+) = op1.owner#
 and op2.obj# (+) = s.plsql_object_id and up2.user# (+) = op2.owner#
 and p1.obj# (+) = s.plsql_entry_object_id and p1.procedure# (+) = s.plsql_entry_subprogram_id
 and p2.obj# (+) = s.plsql_object_id and p2.procedure# (+) = s.plsql_subprogram_id

/*
select * from gv$event_name where name = 'latch: library cache'
p1=address
p2=number
p3=tries
select * from gv$active_session_history where event = 'latch: library cache'
*/
