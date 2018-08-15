with
param as
(
 select
  &<name="Begin" type="date" default="sysdate-1/24/60"> begin_date,
  &<name="End" type="date" default="sysdate"> end_date
 from dual
)
select
-- ash.*,
-- ash.current_obj#,
-- ash.current_file#,
-- ash.p1, ash.p1text,
 ash.sample_id,
 ash.sample_time,
 ash.inst_id "I",
 u.name "User",
 (select s.osuser from gv$session s where s.sid = ash.session_id and s.serial# = ash.session_serial# and rownum = 1) osuser,
 ash.session_id "SID", ash.session_serial# "SERIAL",
 decode(o.name,null,(select 'TS='||tablespace_name from dba_data_files df where df.file_id = ash.current_file#),uo.name||'.'||o.name||'.'||o.subname) "Object",
 ash.current_obj#,
 ash.sql_id, ash.top_level_sql_id "top_sql_id", ash.sql_child_number "CHILD", ash.sql_plan_hash_value "PLAN_HASH",
 up1.name||'.'||op1.name||'.'||p1.procedurename "Entry Proc",
 up2.name||'.'||op2.name||'.'||p2.procedurename "Procedure",
 ash.program, ash.module, ash.action, ash.machine, ash.client_id,
 ash.blocking_session "B_SES", ash.blocking_session_serial# "B_SER",
-- (select u2.name||'/'||ash2.program||'/'||ash2.module
--  from gv$active_session_history ash2, sys.user$ u2
--  where ash2.sample_id = ash.sample_id
--  and ash2.session_id = ash.blocking_session and ash2.session_serial# = ash.blocking_session_serial#
--  and u2.user# = ash2.user_id and rownum = 1) b_session,
-- (select u2.name||'/'||ash2.program||'/'||ash2.module
--  from gv$active_session_history ash2, sys.user$ u2
--  where ash2.sample_id between ash.sample_id-5 and ash.sample_id+5
--  and ash2.session_id = ash.blocking_session and ash2.session_serial# = ash.blocking_session_serial#
--  and u2.user# = ash2.user_id and rownum = 1) b_session,
 (select u3.name||'/'||s3.program||'/'||s3.module
  from gv$session s3, sys.user$ u3
  where s3.sid = ash.blocking_session and s3.serial# = ash.blocking_session_serial#
  and u3.user# (+) = s3.user# and rownum = 1) b_session_2,
-- (select u3.name||'/'||s3.program||'/'||s3.module
--  from gv$session s4
--  where s4.sid = ash.blocking_session and s4.serial# = ash.blocking_session_serial#
--  and rownum = 1) b_session_3,
 decode(ash.wait_time,0,'WAIT','ON CPU') "Type", 
 ash.event "Wait",
 case
  when ash.event = 'cursor: pin S wait on X' then 'BSID='||decode(trunc(ash.p2/4294967296),0,trunc(ash.p2/65536),trunc(ash.p2/4294967296))
  when ash.event = 'enq: TM - contention' then 'MODE='||mod(ash.p1,16)||' OBJ='||(select owner||'.'||object_name||'.'||subobject_name from dba_objects where object_id = ash.p2)||' P3='||ash.p3
  --NAME chr(bitand(ash.p1,-16777216)/16777215)||chr(bitand(ash.p1,16711680)/65535) -- enqueue TX TM and so on
--  when e.event_name = 'library cache lock' then 'OBJ='||(select o.kglnaown||'.'||o.kglnaobj from sys.x_$kglob o where o.kglhdadr = trim(to_char(ash.p1,'XXXXXXXXXXXXXXXX')))

  --MODE mod(ash.p1,16)
  else 'P1='||ash.p1||' P2='||ash.p2||' P3='||ash.p3
 end info,
-- ash.*,
 (ash.wait_time+ash.time_waited) "Time"
from param p, gv$active_session_history ash,
sys.user$ u,
sys.obj$ o, sys.user$ uo,
sys.obj$ op1, sys.user$ up1, sys.procedureinfo$ p1,
sys.obj$ op2, sys.user$ up2, sys.procedureinfo$ p2
where
p.begin_date <= ash.sample_time and ash.sample_time < p.end_date
and u.user# (+) = ash.user_id
and o.obj# (+) = ash.current_obj#
and uo.user# (+) = o.owner#
and op1.obj# (+) = ash.plsql_entry_object_id and up1.user# (+) = op1.owner#
and op2.obj# (+) = ash.plsql_object_id and up2.user# (+) = op2.owner#
and p1.obj# (+) = ash.plsql_entry_object_id and p1.procedure# (+) = ash.plsql_entry_subprogram_id
and p2.obj# (+) = ash.plsql_object_id and p2.procedure# (+) = ash.plsql_subprogram_id
and ash.inst_id like &<name="inst_id" type="string" default="%">
and ash.session_id like &<name="SID" type="string" default="%">
and nvl(u.name,'-') like &<name="User" type="string" default="%">
and nvl(decode(o.name,null,(select tablespace_name from dba_data_files df where df.file_id = ash.current_file#),uo.name||'.'||o.name||'.'||o.subname),'-') like &<name="Object" type="string" default="%">
and nvl(o.name,'-') like &<name="Object" type="string" default="%">
and nvl(op1.name,'-')||'.'||p1.procedurename like &<name="Entry Proc" type="string" default="%">
and nvl(ash.sql_id,'-') like &<name="SQL ID" type="string" default="%">
and nvl(ash.machine,'-') like &<name="Machine" type="string" default="%">
and nvl(ash.program,'-') like &<name="Program" type="string" default="%">
and nvl(ash.module,'-') like &<name="Module" type="string" default="%">
and nvl(ash.action,'-') like &<name="Action" type="string" default="%">
and nvl(ash.event,'-') like &<name="Wait" type="string" default="%">
--and (ash.session_id, ash.session_serial#) in (select sid, serial# from gv$session where terminal = 'EK-MNG-PC036')
--and ash.program like '%srv-has-sg2%'
--and ash.module != 'backup incr datafile'
--and ash.sql_id = 'cm93tszbzth5p'
--and ash.session_id = 3404 and ash.session_serial# = 59903
--and ash.inst_id = 3
--and ash.
-- and ash.blocking_session_status = 'VALID'
-- and ash.current_file# = 60 and ash.current_block# = 109781
-- and ash.current_file# = 225 and ash.current_block# = 601

--and ash.event not in ('db file sequential read','db file parallel read','db file scattered read',
--'db file parallel write','ARCH wait on SENDREQ','log file sync','log file parallel write','gc buffer busy',
--'Log archive I/O','read by other session','gc current grant 2-way','log file sequential read','gc cr disk read',
--'gc cr grant 2-way','gc current grant busy','gc cr block 2-way','gc cr request','direct path read',
--'gc cr multi block request','gc current block 2-way','gc current block busy','gc cr block busy',
--'control file sequential read','gc cr grant congested','SQL*Net more data to client','gcs log flush sync',
--'gc current multi block request','LGWR wait for redo copy','buffer busy waits','gc current request',
--'gc cr block congested','gc current block congested','gc current grant congested','SQL*Net break/reset to client',
--'SQL*Net more data from client','direct path write temp','cr request retry','SQL*Net more data from dblink',
--'TCP Socket (KGAS)','PX Deq Credit: send blkd','DFS lock handle','latch: cache buffers chains','PX Deq: Table Q Get Keys'
--)
order by ash.sample_time

