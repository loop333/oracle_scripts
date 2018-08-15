select
 s.inst_id "I",
 s.username "User",
 s.osuser,
 s.sid "SID", s.serial# "SERIAL",
 decode(o.name,null,(select 'TS='||tablespace_name from dba_data_files df where df.file_id = s.row_wait_file#),uo.name||'.'||o.name||'.'||o.subname) "Object",
 s.sql_id, s.sql_child_number "CHILD", s.sql_hash_value "PLAN_HASH",
 up1.name||'.'||op1.name||'.'||p1.procedurename "Entry Proc",
 up2.name||'.'||op2.name||'.'||p2.procedurename "Procedure",
 s.machine, s.terminal, s.program, s.module, s.action, s.client_info, s.client_identifier,
 s.blocking_instance "B_I", s.blocking_session "B_SES",
 (select s2.username||'/'||s2.program||'/'||s2.module
  from gv$session s2
  where s2.inst_id = s.blocking_instance and s2.sid = s.blocking_session) b_session,
 decode(s.wait_time,0,'WAIT','ON CPU') "Type", 
 s.event "Wait",
 s.wait_time "Time",
 s.seconds_in_wait "SEC_WAIT"
from gv$session s,
sys.obj$ o, sys.user$ uo,
sys.obj$ op1, sys.user$ up1, sys.procedureinfo$ p1,
sys.obj$ op2, sys.user$ up2, sys.procedureinfo$ p2
where
o.obj# (+) = s.row_wait_obj#
and uo.user# (+) = o.owner#
and op1.obj# (+) = s.plsql_entry_object_id and up1.user# (+) = op1.owner#
and op2.obj# (+) = s.plsql_object_id and up2.user# (+) = op2.owner#
and p1.obj# (+) = s.plsql_entry_object_id and p1.procedure# (+) = s.plsql_entry_subprogram_id
and p2.obj# (+) = s.plsql_object_id and p2.procedure# (+) = s.plsql_subprogram_id
and s.sid like &<name="SID" type="string" default="%">
and nvl(s.username,'-') like &<name="User" type="string" default="%">
and nvl(decode(o.name,null,(select tablespace_name from dba_data_files df where df.file_id = s.row_wait_file#),uo.name||'.'||o.name||'.'||o.subname),'-') like &<name="Object" type="string" default="%">
--and nvl(o.name,'-') like &<name="Object" type="string" default="%">
and nvl(op1.name,'-')||'.'||p1.procedurename like &<name="Entry Proc" type="string" default="%">
and nvl(s.sql_id,'-') like &<name="SQL ID" type="string" default="%">
and nvl(s.program,'-') like &<name="Program" type="string" default="%">
and nvl(s.module,'-') like &<name="Module" type="string" default="%">
and nvl(s.action,'-') like &<name="Action" type="string" default="%">
and nvl(s.event,'-') like &<name="Wait" type="string" default="%">

