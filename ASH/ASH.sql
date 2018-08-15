with
param as
(
 select &<name="Begin" type="date"> begin_date,
        &<name="End" type="date"> end_date
 from dual
)
select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
-- ash.*,
-- decode(e.event_name,'cursor: pin S wait on X',to_number(substr(to_char(ash.p2,'XXXXXXXXXXXX'),1,5),'XXXX'),null) blocking_sid,
 to_char(ash.sample_time,'DD.MM.YYYY HH24:MI:SS.FF') sample_time,
-- ash.pga_allocated,
 ash.snap_id,
-- ash.sample_id,
-- ash.user_id,
 ash.instance_number "I",
 u.name "User",
 ash.session_id "SID", ash.session_serial# "Serial", ash.qc_session_id, ash.qc_instance_id,
 ash.sql_opcode,
 ash.sql_id,
-- ash.top_level_sql_id,
 ash.sql_plan_hash_value "Plan Hash",
 decode(o.name,null,(select 'TS='||tablespace_name from dba_data_files df where df.file_id = ash.current_file#),uo.name||'.'||o.name||'.'||o.subname) "Object",
 decode(ash.user_id,0,regexp_substr(ash.program,
  '(ARC|LGWR|DBW|LMS|LMD|CJQ|QMNC|SMON|CKPT|PMON|LMON|LCK|MMON|rman|DIAG|racgimon|PZ|q\d{3}|J\d{3}|m\d{3}|I.\d{2})'),null) "SYS",
 up1.name||'.'||op1.name||'.'||p1.procedurename "Entry Proc",
 up2.name||'.'||op2.name||'.'||p2.procedurename "Procedure",
 ash.program,
 ash.module,
 ash.action,
 ash.client_id,
 ash.machine,
 case
  when ash.blocking_session between 4294967291 and 4294967295 then to_number(NULL)
  else ash.blocking_session
 end "b SID",
 case
  when ash.blocking_session between 4294967291 and 4294967295 then to_number(NULL)
  else ash.blocking_session_serial#
 end "b Serial",
 (select u2.name||'/'||ash2.program||'/'||ash2.module
  from sys.wrh$_active_session_history ash2, sys.user$ u2
  where ash2.dbid = ash.dbid and ash2.snap_id = ash.snap_id and ash2.sample_id = ash.sample_id
  and ash2.session_id = ash.blocking_session and ash2.session_serial# = ash.blocking_session_serial#
  and u2.user# = ash2.user_id) b_session,
 decode(ash.wait_time,0,'WAIT','ON CPU') "Type", 
 e.event_name "Wait",
 (ash.wait_time+ash.time_waited) "Time",
-- ash.tm_delta_time, ash.tm_delta_cpu_time, ash.tm_delta_db_time, ash.delta_time,
 to_char(ash.sample_time,'HH24:MI:SS') "ST",
 case
  when e.event_name = 'cursor: pin S wait on X' then 'BSID='||decode(trunc(ash.p2/4294967296),0,trunc(ash.p2/65536),trunc(ash.p2/4294967296))
  when e.event_name = 'enq: TM - contention' then 'MODE='||mod(ash.p1,16)||' OBJ='||(select owner||'.'||object_name||'.'||subobject_name from dba_objects where object_id = ash.p2)||' P3='||ash.p3
  --NAME chr(bitand(ash.p1,-16777216)/16777215)||chr(bitand(ash.p1,16711680)/65535) -- enqueue TX TM and so on
--  when e.event_name = 'library cache lock' then 'OBJ='||(select o.kglnaown||'.'||o.kglnaobj from sys.x_$kglob o where o.kglhdadr = trim(to_char(ash.p1,'XXXXXXXXXXXXXXXX')))

  --MODE mod(ash.p1,16)
  else 'P1='||ash.p1||' P2='||ash.p2||' P3='||ash.p3
 end info,
 to_char(ash.sample_time,'HH24:MI:SS') "time"
from param p, sys.wrm$_snapshot snap, sys.wrh$_active_session_history ash, sys.wrh$_event_name e,
sys.user$ u,
sys.obj$ o, sys.user$ uo,
sys.obj$ op1, sys.user$ up1, sys.procedureinfo$ p1,
sys.obj$ op2, sys.user$ up2, sys.procedureinfo$ p2
where
snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
and ash.dbid = (select dbid from gv$database where rownum = 1) and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number
and e.dbid (+) = ash.dbid and e.event_id (+) = ash.event_id
and ash.sample_time between p.begin_date and p.end_date
and u.user# (+) = ash.user_id
and o.obj# (+) = ash.current_obj#
and uo.user# (+) = o.owner#
and op1.obj# (+) = ash.plsql_entry_object_id and up1.user# (+) = op1.owner#
and op2.obj# (+) = ash.plsql_object_id and up2.user# (+) = op2.owner#
and p1.obj# (+) = ash.plsql_entry_object_id and p1.procedure# (+) = ash.plsql_entry_subprogram_id
and p2.obj# (+) = ash.plsql_object_id and p2.procedure# (+) = ash.plsql_subprogram_id
and ash.instance_number like &<name="Instance" type="string" default="%">
and ash.session_id like &<name="SID" type="string" default="%">
and ash.session_serial# like &<name="SERIAL" type="string" default="%">
and nvl(u.name,'-') like &<name="User" type="string" default="%">
and nvl(o.name,'-') like &<name="Object" type="string" default="%">
and nvl(ash.sql_id,'-') like &<name="SQL_ID" type="string" default="%">
and nvl(op1.name,'-') like &<name="Entry Proc (Package or Procedure)" type="string" default="%">
and nvl(op2.name,'-') like &<name="Procedure (Package or Procedure)" type="string" default="%">
and nvl(ash.program,'-') like &<name="Program" type="string" default="%">
and nvl(ash.module,'-') like &<name="Module" type="string" default="%">
and nvl(ash.action,'-') like &<name="Action" type="string" default="%">
and nvl(ash.machine,'-') like &<name="Machine" type="string" default="%">
and nvl(e.event_name,'-') like &<name="Wait" type="string" default="%">
--and (ash.session_id != 3081 and ash.qc_session_id != 3081)
--and (ash.session_id != 458 and ash.qc_session_id != 458)
--and (ash.session_id != 4417 and ash.qc_session_id != 4417)
--and (ash.session_id != 3199 and ash.qc_session_id != 3199)
--and (ash.session_id != 845 and ash.qc_session_id != 845)
--and ash.sql_opcode in (2,189,6)
&<name="Critical" checkbox="and 1=1," suffix="
and e.event_name not in (
--'affinity expansion in replay',-- Class: Other, P1: , P2:, P3:
--'alter rbs offline',-- Class: Administrative, P1: , P2:, P3:
--'alter system set dispatcher',-- Class: Administrative, P1: waited, P2:, P3:
'ARCH random i/o',-- Class: System I/O, P1: , P2:, P3:
'ARCH sequential i/o',-- Class: System I/O, P1: , P2:, P3:
'ARCH wait for archivelog lock',-- Class: Other, P1: , P2:, P3:
'ARCH wait for flow-control',-- Class: Network, P1: , P2:, P3:
'ARCH wait for net re-connect',-- Class: Network, P1: , P2:, P3:
'ARCH wait for netserver detach',-- Class: Network, P1: , P2:, P3:
'ARCH wait for netserver init 1',-- Class: Network, P1: , P2:, P3:
'ARCH wait for netserver init 2',-- Class: Network, P1: , P2:, P3:
'ARCH wait for netserver start',-- Class: Network, P1: , P2:, P3:
'ARCH wait for pending I/Os',-- Class: System I/O, P1: , P2:, P3:
'ARCH wait for process death 1',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process death 2',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process death 3',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process death 4',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process death 5',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process start 1',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process start 2',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process start 3',-- Class: Other, P1: , P2:, P3:
'ARCH wait for process start 4',-- Class: Other, P1: , P2:, P3:
'ARCH wait on ATTACH',-- Class: Network, P1: , P2:, P3:
'ARCH wait on c/f tx acquire 1',-- Class: Other, P1: , P2:, P3:
'ARCH wait on c/f tx acquire 2',-- Class: Other, P1: , P2:, P3:
'ARCH wait on DETACH',-- Class: Network, P1: , P2:, P3:
'ARCH wait on SENDREQ',-- Class: Network, P1: , P2:, P3:
--'ASM background running',-- Class: Other, P1: , P2:, P3:
--'ASM background starting',-- Class: Other, P1: , P2:, P3:
--'ASM background timer',-- Class: Idle, P1: , P2:, P3:
--'ASM COD rollback operation completion',-- Class: Administrative, P1: dismount force, P2:, P3:
--'ASM db client exists',-- Class: Other, P1: , P2:, P3:
--'ASM internal hang test',-- Class: Other, P1: test #, P2:, P3:
--'ASM mount : wait for heartbeat',-- Class: Administrative, P1: , P2:, P3:
--'ASM PST query : wait for [PM][grp][0] grant',-- Class: Cluster, P1: , P2:, P3:
--'AWR Flush',-- Class: Other, P1: , P2:, P3:
--'AWR Metric Capture',-- Class: Other, P1: , P2:, P3:
'Backup: sbtbackup',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtclose',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtclose2',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtcommand',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtend',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbterror',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtinfo',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtinfo2',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtinit',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtinit2',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtopen',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcbackup',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpccancel',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpccommit',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcend',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcquerybackup',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcqueryrestore',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcrestore',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcstart',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcstatus',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtpcvalidate',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtread',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtread2',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtremove',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtremove2',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtrestore',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtwrite',-- Class: Administrative, P1: , P2:, P3:
'Backup: sbtwrite2',-- Class: Administrative, P1: , P2:, P3:
'Backup: MML write backup piece',
--'BFILE check if exists',-- Class: Other, P1:  , P2: , P3: 
--'BFILE check if open',-- Class: Other, P1:  , P2: , P3: 
--'BFILE closure',-- Class: Other, P1:  , P2: , P3: 
--'BFILE get length',-- Class: Other, P1:  , P2: , P3: 
--'BFILE get name object',-- Class: Other, P1:  , P2: , P3: 
--'BFILE get path object',-- Class: Other, P1:  , P2: , P3: 
--'BFILE internal seek',-- Class: Other, P1:  , P2: , P3: 
--'BFILE open',-- Class: Other, P1:  , P2: , P3: 
--'BFILE read',-- Class: User I/O, P1:  , P2: , P3: 
--'block change tracking buffer space',-- Class: Other, P1: , P2:, P3:
--'buffer busy',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'buffer busy waits',-- Class: Concurrency, P1: file#, P2:block#, P3:class#
--'buffer deadlock',-- Class: Other, P1: dba, P2:class*10+mode, P3:flag
--'buffer dirty disabled',-- Class: Other, P1: group#, P2:, P3:
--'buffer exterminate',-- Class: Other, P1: file#, P2:block#, P3:buf_ptr
--'buffer freelistbusy',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'buffer invalidation wait',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'buffer latch',-- Class: Other, P1: latch addr, P2:chain#, P3:
--'buffer pool resize',-- Class: Administrative, P1: buffer pool id, P2:current size, P3:new size
--'buffer read retry',-- Class: User I/O, P1: file#, P2:block#, P3:
--'buffer rememberlist busy',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'buffer resize',-- Class: Other, P1: , P2:, P3:
--'buffer write wait',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'buffer writeList full',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'CGS skgxn join retry',-- Class: Other, P1: retry count, P2:, P3:
--'CGS wait for IPC msg',-- Class: Other, P1: , P2:, P3:
--'change tracking file parallel write',-- Class: Other, P1: blocks, P2:requests, P3:
--'change tracking file synchronous read',-- Class: Other, P1: block#, P2:blocks, P3:
--'change tracking file synchronous write',-- Class: Other, P1: block#, P2:blocks, P3:
--'check CPU wait times',-- Class: Other, P1: , P2:, P3:
--'checkpoint advanced',-- Class: Other, P1: group#, P2:, P3:
--'checkpoint completed',-- Class: Configuration, P1: , P2:, P3:
--'class slave wait',-- Class: Idle, P1: slave id, P2:, P3:
--'cleanup of aborted process',-- Class: Other, P1: location, P2:, P3:
--'Cluster stablization wait',-- Class: Other, P1: , P2:, P3:
--'Cluster Suspension wait',-- Class: Other, P1: , P2:, P3:
--'control file diagnostic dump',-- Class: Other, P1: type, P2:param, P3:
--'control file heartbeat',-- Class: Other, P1: , P2:, P3:
'control file parallel write',-- Class: System I/O, P1: files, P2:block#, P3:requests
'control file sequential read',-- Class: System I/O, P1: file#, P2:block#, P3:blocks
'control file single write',-- Class: System I/O, P1: file#, P2:block#, P3:blocks
--'cr request retry',-- Class: Other, P1: file#, P2:block#, P3:
--'cursor: mutex S',-- Class: Concurrency, P1: idn, P2:value, P3:where|sleeps
--'cursor: mutex X',-- Class: Concurrency, P1: idn, P2:value, P3:where|sleeps
--'cursor: pin S',-- Class: Other, P1: idn, P2:value, P3:where|sleeps
--'cursor: pin S wait on X',-- Class: Concurrency, P1: idn, P2:value, P3:where|sleeps
--'cursor: pin X',-- Class: Other, P1: idn, P2:value, P3:where|sleeps
--'Data file init write',-- Class: User I/O, P1: count, P2:intr, P3:timeout
--'Data Guard broker: single instance',-- Class: Other, P1: Data Guard broker: single instance, P2:, P3:
--'Data Guard broker: wait upon ORA-12850 error',-- Class: Other, P1: waiting for retrying the query to mask ORA-12850 error, P2:, P3:
--'Data Guard: process clean up',-- Class: Other, P1: , P2:, P3:
--'Data Guard: process exit',-- Class: Other, P1: , P2:, P3:
--'Datapump dump file I/O',-- Class: User I/O, P1: count, P2:intr, P3:timeout
'db file parallel read',-- Class: User I/O, P1: files, P2:blocks, P3:requests
'db file parallel write',-- Class: System I/O, P1: requests, P2:interrupt, P3:timeout
'db file scattered read',-- Class: User I/O, P1: file#, P2:block#, P3:blocks
'db file sequential read',-- Class: User I/O, P1: file#, P2:block#, P3:blocks
'db file single write',-- Class: User I/O, P1: file#, P2:block#, P3:blocks
--'DBFG waiting for reply',-- Class: Other, P1: , P2:, P3:
--'dbms_file_transfer I/O',-- Class: User I/O, P1: count, P2:intr, P3:timeout
--'DBMS_LDAP: LDAP operation ',-- Class: Other, P1: , P2:, P3:
--'debugger command',-- Class: Other, P1: , P2:, P3:
--'dedicated server timer',-- Class: Network, P1: wait event, P2:, P3:
--'DFS db file lock',-- Class: Other, P1: file#, P2:, P3:
--'DFS lock handle',-- Class: Other, P1: type|mode, P2:id1, P3:id2
--'DG Broker configuration file I/O',-- Class: User I/O, P1: count, P2:intr, P3:timeout
--'DIAG idle wait',-- Class: Idle, P1: component, P2:where, P3:wait time(millisec)
'direct path read',-- Class: User I/O, P1: file number, P2:first dba, P3:block cnt
'direct path read temp',-- Class: User I/O, P1: file number, P2:first dba, P3:block cnt
'direct path write',-- Class: User I/O, P1: file number, P2:first dba, P3:block cnt
'direct path write temp',-- Class: User I/O, P1: file number, P2:first dba, P3:block cnt
--'dispatcher listen timer',-- Class: Network, P1: sleep time, P2:, P3:
--'dispatcher shutdown',-- Class: Other, P1: waited, P2:, P3:
--'dispatcher timer',-- Class: Idle, P1: sleep time, P2:, P3:
--'dma prepare busy',-- Class: Other, P1: group, P2:obj#, P3:block#
--'dupl. cluster key',-- Class: Other, P1: dba, P2:, P3:
--'EMON idle wait',-- Class: Idle, P1: , P2:, P3:
--'events in waitclass Other',-- Class: Other, P1: , P2:, P3:
--'extent map load/unlock',-- Class: Other, P1: group, P2:file, P3:extent
--'FAL archive wait 1 sec for REOPEN minimum',-- Class: Other, P1: , P2:, P3:
--'flashback buf free by RVWR',-- Class: Other, P1: , P2:, P3:
--'flashback free VI log',-- Class: Other, P1: , P2:, P3:
--'flashback log switch',-- Class: Other, P1: , P2:, P3:
--'free buffer waits',-- Class: Configuration, P1: file#, P2:block#, P3:set-id#
--'free global transaction table entry',-- Class: Other, P1: tries, P2:, P3:
--'free process state object',-- Class: Other, P1: , P2:, P3:
'gc assume',-- Class: Cluster, P1: le, P2:, P3:
'gc block recovery request',-- Class: Cluster, P1: file#, P2:block#, P3:class#
'gc buffer busy',-- Class: Cluster, P1: file#, P2:block#, P3:id#
'gc claim',-- Class: Cluster, P1: , P2:, P3:
'gc cr block busy',-- Class: Cluster, P1: , P2:, P3:
'gc cr block congested',-- Class: Cluster, P1: , P2:, P3:
'gc cr block lost',-- Class: Cluster, P1: , P2:, P3:
'gc cr block unknown',-- Class: Cluster, P1: , P2:, P3:
'gc cr block 2-way',-- Class: Cluster, P1: , P2:, P3:
'gc cr block 3-way',-- Class: Cluster, P1: , P2:, P3:
'gc cr cancel',-- Class: Cluster, P1: le, P2:, P3:
'gc cr disk read',-- Class: Cluster, P1: , P2:, P3:
'gc cr disk request',-- Class: Cluster, P1: file#, P2:block#, P3:class#
'gc cr failure',-- Class: Cluster, P1: , P2:, P3:
'gc cr grant busy',-- Class: Cluster, P1: , P2:, P3:
'gc cr grant congested',-- Class: Cluster, P1: , P2:, P3:
'gc cr grant unknown',-- Class: Cluster, P1: , P2:, P3:
'gc cr grant 2-way',-- Class: Cluster, P1: , P2:, P3:
'gc cr multi block request',-- Class: Cluster, P1: file#, P2:block#, P3:class#
'gc cr request',-- Class: Cluster, P1: file#, P2:block#, P3:class#
'gc current block busy',-- Class: Cluster, P1: , P2:, P3:
'gc current block congested',-- Class: Cluster, P1: , P2:, P3:
'gc current block lost',-- Class: Cluster, P1: , P2:, P3:
'gc current block unknown',-- Class: Cluster, P1: , P2:, P3:
'gc current block 2-way',-- Class: Cluster, P1: , P2:, P3:
'gc current block 3-way',-- Class: Cluster, P1: , P2:, P3:
'gc current cancel',-- Class: Cluster, P1: le, P2:, P3:
'gc current grant busy',-- Class: Cluster, P1: , P2:, P3:
'gc current grant congested',-- Class: Cluster, P1: , P2:, P3:
'gc current grant unknown',-- Class: Cluster, P1: , P2:, P3:
'gc current grant 2-way',-- Class: Cluster, P1: , P2:, P3:
'gc current multi block request',-- Class: Cluster, P1: file#, P2:block#, P3:id#
'gc current request',-- Class: Cluster, P1: file#, P2:block#, P3:id#
'gc current retry',-- Class: Cluster, P1: , P2:, P3:
'gc current split',-- Class: Cluster, P1: , P2:, P3:
'gc domain validation',-- Class: Cluster, P1: file#, P2:block#, P3:class#
'gc freelist',-- Class: Cluster, P1: , P2:, P3:
'gc object scan',-- Class: Cluster, P1: , P2:, P3:
'gc prepare',-- Class: Cluster, P1: , P2:, P3:
'gc quiesce',-- Class: Cluster, P1: , P2:, P3:
'gc recovery free',-- Class: Cluster, P1: , P2:, P3:
'gc recovery quiesce',-- Class: Cluster, P1: , P2:, P3:
'gc remaster',-- Class: Cluster, P1: file#, P2:block#, P3:class#
--'gcs ddet enter server mode',-- Class: Other, P1: , P2:, P3:
--'gcs domain validation',-- Class: Other, P1: cluinc, P2:rcvinc, P3:
--'gcs drm freeze begin',-- Class: Other, P1: , P2:, P3:
--'gcs drm freeze in enter server mode',-- Class: Other, P1: , P2:, P3:
--'gcs enter server mode',-- Class: Other, P1: , P2:, P3:
--'GCS lock cancel',-- Class: Other, P1: le, P2:, P3:
--'GCS lock cvt S',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock cvt X',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock esc',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock esc X',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock open',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock open S',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS lock open X',-- Class: Other, P1: group, P2:obj#, P3:block#
--'gcs log flush sync',-- Class: Other, P1: waittime, P2:poll, P3:event
--'GCS recovery lock convert',-- Class: Other, P1: group, P2:obj#, P3:block#
--'GCS recovery lock open',-- Class: Other, P1: group, P2:obj#, P3:block#
--'gcs remastering wait for read latch',-- Class: Other, P1: , P2:, P3:
--'gcs remastering wait for write latch',-- Class: Other, P1: , P2:, P3:
--'gcs remote message',-- Class: Idle, P1: waittime, P2:poll, P3:event
--'gcs resource directory to be unfrozen',-- Class: Other, P1: , P2:, P3:
--'gcs to be enabled',-- Class: Other, P1: , P2:, P3:
--'ges cached resource cleanup',-- Class: Other, P1: waittime, P2:, P3:
--'ges cancel',-- Class: Other, P1: , P2:, P3:
--'ges cgs registration',-- Class: Other, P1: where, P2:, P3:
--'ges enter server mode',-- Class: Other, P1: , P2:, P3:
--'ges generic event',-- Class: Other, P1: , P2:, P3:
--'ges global resource directory to be frozen',-- Class: Other, P1: , P2:, P3:
--'ges inquiry response',-- Class: Other, P1: type|mode|where, P2:id1, P3:id2
--'ges lmd and pmon to attach',-- Class: Other, P1: , P2:, P3:
--'ges LMD suspend for testing event',-- Class: Other, P1: , P2:, P3:
--'ges LMD to inherit communication channels',-- Class: Other, P1: , P2:, P3:
--'ges LMD to shutdown',-- Class: Other, P1: , P2:, P3:
--'ges lmd/lmses to freeze in rcfg - mrcvr',-- Class: Other, P1: , P2:, P3:
--'ges lmd/lmses to unfreeze in rcfg - mrcvr',-- Class: Other, P1: , P2:, P3:
--'ges LMON for send queues',-- Class: Other, P1: , P2:, P3:
--'ges LMON to get to FTDONE ',-- Class: Other, P1: , P2:, P3:
--'ges LMON to join CGS group',-- Class: Other, P1: , P2:, P3:
--'ges master to get established for SCN op',-- Class: Other, P1: , P2:, P3:
--'ges performance test completion',-- Class: Other, P1: , P2:, P3:
--'ges pmon to exit',-- Class: Other, P1: , P2:, P3:
--'ges process with outstanding i/o',-- Class: Other, P1: pid, P2:, P3:
--'ges reconfiguration to start',-- Class: Other, P1: , P2:, P3:
--'ges remote message',-- Class: Idle, P1: waittime, P2:loop, P3:p3
--'ges resource cleanout during enqueue open',-- Class: Other, P1: , P2:, P3:
--'ges resource cleanout during enqueue open-cvt',-- Class: Other, P1: , P2:, P3:
--'ges resource directory to be unfrozen',-- Class: Other, P1: , P2:, P3:
--'ges retry query node',-- Class: Other, P1: , P2:, P3:
--'ges reusing os pid',-- Class: Other, P1: pid, P2:count, P3:
--'ges user error',-- Class: Other, P1: error, P2:, P3:
--'ges wait for lmon to be ready',-- Class: Other, P1: , P2:, P3:
--'ges1 LMON to wake up LMD - mrcvr',-- Class: Other, P1: , P2:, P3:
--'ges2 LMON to wake up LMD - mrcvr',-- Class: Other, P1: , P2:, P3:
--'ges2 LMON to wake up lms - mrcvr 2',-- Class: Other, P1: , P2:, P3:
--'ges2 LMON to wake up lms - mrcvr 3',-- Class: Other, P1: , P2:, P3:
--'ges2 proc latch in rm latch get 1',-- Class: Other, P1: , P2:, P3:
--'ges2 proc latch in rm latch get 2',-- Class: Other, P1: , P2:, P3:
--'global cache busy',-- Class: Other, P1: group, P2:file#, P3:block#
--'global enqueue expand wait',-- Class: Other, P1: , P2:, P3:
--'GV$: slave acquisition retry wait time',-- Class: Other, P1: , P2:, P3:
--'HS message to agent',-- Class: Idle, P1: , P2:, P3:
--'imm op',-- Class: Other, P1: msg ptr, P2:, P3:
--'inactive session',-- Class: Other, P1: session#, P2:waited, P3:
--'inactive transaction branch',-- Class: Other, P1: branch#, P2:waited, P3:
--'index block split',-- Class: Other, P1: rootdba, P2:level, P3:childdba
--'index (re)build online cleanup',-- Class: Administrative, P1: object, P2:mode, P3:wait
--'index (re)build online merge',-- Class: Administrative, P1: object, P2:mode, P3:wait
--'index (re)build online start',-- Class: Administrative, P1: object, P2:mode, P3:wait
--'instance state change',-- Class: Other, P1: layer, P2:value, P3:waited
'io done',-- Class: System I/O, P1: msg ptr, P2:, P3:
--'i/o slave wait',-- Class: Idle, P1: msg ptr, P2:, P3:
--'IPC busy async request',-- Class: Other, P1: , P2:, P3:
--'IPC send completion sync',-- Class: Other, P1: send count, P2:, P3:
--'IPC wait for name service busy',-- Class: Other, P1: , P2:, P3:
--'IPC waiting for OSD resources',-- Class: Other, P1: , P2:, P3:
--'job scheduler coordinator slave wait',-- Class: Other, P1: , P2:, P3:
--'jobq slave shutdown wait',-- Class: Other, P1: , P2:, P3:
--'jobq slave TJ process wait',-- Class: Other, P1: , P2:, P3:
--'jobq slave wait',-- Class: Idle, P1: , P2:, P3:
--'JS coord start wait',-- Class: Administrative, P1: , P2:, P3:
--'JS external job',-- Class: Idle, P1: , P2:, P3:
--'JS kgl get object wait',-- Class: Administrative, P1: , P2:, P3:
--'JS kill job wait',-- Class: Administrative, P1: , P2:, P3:
--'kcbzps',-- Class: Other, P1: , P2:, P3:
--'kcrrrcp',-- Class: Other, P1: , P2:, P3:
--'kdblil wait before retrying ORA-54',-- Class: Other, P1: , P2:, P3:
--'kdic_do_merge',-- Class: Other, P1: , P2:, P3:
--'kfcl: instance recovery',-- Class: Other, P1: group, P2:obj#, P3:block#
--'kfk: async disk IO',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'kgltwait',-- Class: Other, P1: , P2:, P3:
--'kjbdomalc allocate recovery domain - retry',-- Class: Other, P1: , P2:, P3:
--'kjbdrmcvtq lmon drm quiesce: ping completion',-- Class: Other, P1: , P2:, P3:
--'kjbopen wait for recovery domain attach',-- Class: Other, P1: , P2:, P3:
--'KJC: Wait for msg sends to complete',-- Class: Other, P1: msg, P2:dest|rcvr, P3:mtype
--'kjctcisnd: Queue/Send client message',-- Class: Other, P1: , P2:, P3:
--'kjctssqmg: quick message send wait',-- Class: Other, P1: , P2:, P3:
--'kjudomatt wait for recovery domain attach',-- Class: Other, P1: , P2:, P3:
--'kjudomdet wait for recovery domain detach',-- Class: Other, P1: , P2:, P3:
--'kjxgrtest',-- Class: Other, P1: , P2:, P3:
--'kkdlgon',-- Class: Other, P1: , P2:, P3:
--'kkdlhpon',-- Class: Other, P1: , P2:, P3:
--'kkdlsipon',-- Class: Other, P1: , P2:, P3:
--'kksfbc child completion',-- Class: Other, P1: , P2:, P3:
--'kksfbc research',-- Class: Other, P1: , P2:, P3:
--'kkshgnc reloop',-- Class: Other, P1: , P2:, P3:
--'kksscl hash split',-- Class: Other, P1: , P2:, P3:
--'knpc_acwm_AwaitChangedWaterMark',-- Class: Other, P1: , P2:, P3:
--'knpc_anq_AwaitNonemptyQueue',-- Class: Other, P1: , P2:, P3:
--'knpsmai',-- Class: Other, P1: , P2:, P3:
--'kpodplck wait before retrying ORA-54',-- Class: Other, P1: , P2:, P3:
--'ksbcic',-- Class: Other, P1: , P2:, P3:
--'ksbsrv',-- Class: Other, P1: , P2:, P3:
--'ksdxexeother',-- Class: Other, P1: , P2:, P3:
--'ksdxexeotherwait',-- Class: Other, P1: , P2:, P3:
--'ksfd: async disk IO',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'ksim generic wait event',-- Class: Other, P1: where, P2:wait_count, P3:
--'ksqded',-- Class: Other, P1: , P2:, P3:
--'kst: async disk IO',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'KSV master wait',-- Class: Idle, P1: , P2:, P3:
--'ksv slave avail wait',-- Class: Other, P1: , P2:, P3:
--'ksxr poll remote instances',-- Class: Other, P1: , P2:, P3:
--'ksxr wait for mount shared',-- Class: Other, P1: , P2:, P3:
--'ktfbtgex',-- Class: Other, P1: tsn, P2:, P3:
--'ktm: instance recovery',-- Class: Other, P1: undo segment#, P2:, P3:
--'ktsambl',-- Class: Other, P1: , P2:, P3:
--'kttm2d',-- Class: Other, P1: , P2:, P3:
--'Kupp process shutdown',-- Class: Other, P1: nalive, P2:sleeptime, P3:loop
--'kupp process wait',-- Class: Other, P1: , P2:, P3:
--'kxfxse',-- Class: Other, P1: kxfxse debug wait: stalling for slave 0, P2:, P3:
--'kxfxsp',-- Class: Other, P1: kxfxsp debug wait: stalling for slave 0, P2:, P3:
--'latch activity',-- Class: Other, P1: address, P2:number, P3:process#
--'latch free',-- Class: Other, P1: address, P2:number, P3:tries
--'LGWR random i/o',-- Class: System I/O, P1: , P2:, P3:
--'LGWR sequential i/o',-- Class: System I/O, P1: , P2:, P3:
--'LGWR simulation latency wait',-- Class: Other, P1: , P2:, P3:
--'LGWR wait for redo copy',-- Class: Other, P1: copy latch #, P2:, P3:
--'LGWR wait on ATTACH',-- Class: Network, P1: , P2:, P3:
--'LGWR wait on DETACH',-- Class: Network, P1: , P2:, P3:
--'LGWR wait on full LNS buffer',-- Class: Other, P1: , P2:, P3:
--'LGWR wait on LNS',-- Class: Network, P1: , P2:, P3:
--'LGWR wait on SENDREQ',-- Class: Network, P1: , P2:, P3:
--'LGWR-LNS wait on channel',-- Class: Other, P1: , P2:, P3:
--'library cache load lock',-- Class: Concurrency, P1: object address, P2:lock address, P3:100*mask+namespace
--'library cache lock',-- Class: Concurrency, P1: handle address, P2:lock address, P3:100*mode+namespace
--'library cache pin',-- Class: Concurrency, P1: handle address, P2:pin address, P3:100*mode+namespace
--'library cache revalidation',-- Class: Other, P1:  , P2: , P3: 
--'library cache shutdown',-- Class: Other, P1:  , P2: , P3: 
--'listen endpoint status',-- Class: Other, P1: end-point#, P2:status, P3:
--'LMON global data update',-- Class: Other, P1: , P2:, P3:
--'lms flush message acks',-- Class: Other, P1: loc, P2:tries, P3:
--'LNS ASYNC archive log',-- Class: Idle, P1: , P2:, P3:
--'LNS ASYNC control file txn',-- Class: System I/O, P1: , P2:, P3:
--'LNS ASYNC dest activation',-- Class: Idle, P1: , P2:, P3:
--'LNS ASYNC end of log',-- Class: Idle, P1: , P2:, P3:
--'LNS simulation latency wait',-- Class: Other, P1: , P2:, P3:
--'LNS wait for LGWR redo',-- Class: Other, P1: , P2:, P3:
--'LNS wait on ATTACH',-- Class: Network, P1: , P2:, P3:
--'LNS wait on DETACH',-- Class: Network, P1: , P2:, P3:
--'LNS wait on LGWR',-- Class: Network, P1: , P2:, P3:
--'LNS wait on SENDREQ',-- Class: Network, P1: , P2:, P3:
--'local write wait',-- Class: User I/O, P1: file#, P2:block#, P3:
--'lock close',-- Class: Other, P1: group, P2:lms#, P3:
--'lock deadlock retry',-- Class: Other, P1: , P2:, P3:
--'lock escalate retry',-- Class: Other, P1: , P2:, P3:
--'lock release pending',-- Class: Other, P1: group, P2:file#, P3:block#
--'lock remastering',-- Class: Cluster, P1: , P2:, P3:
--'Log archive I/O',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'log buffer space',-- Class: Configuration, P1: , P2:, P3:
--'Log file init write',-- Class: User I/O, P1: count, P2:intr, P3:timeout
'log file parallel write',-- Class: System I/O, P1: files, P2:blocks, P3:requests
'log file sequential read',-- Class: System I/O, P1: log#, P2:block#, P3:blocks
'log file single write',-- Class: System I/O, P1: log#, P2:block#, P3:blocks
--'log file switch (archiving needed)',-- Class: Configuration, P1: , P2:, P3:
--'log file switch (checkpoint incomplete)',-- Class: Configuration, P1: , P2:, P3:
--'log file switch (clearing log file)',-- Class: Other, P1: , P2:, P3:
--'log file switch completion',-- Class: Configuration, P1: , P2:, P3:
--'log file switch (private strand flush incomplete)',-- Class: Configuration, P1: , P2:, P3:
--'log file sync',-- Class: Commit, P1: buffer#, P2:, P3:
--'log switch/archive',-- Class: Other, P1: thread#, P2:, P3:
--'log write(even)',-- Class: Other, P1: group#, P2:, P3:
--'log write(odd)',-- Class: Other, P1: group#, P2:, P3:
--'Logical Standby Apply shutdown',-- Class: Other, P1: , P2:, P3:
--'Logical Standby dictionary build',-- Class: Other, P1: , P2:, P3:
--'Logical Standby pin transaction',-- Class: Other, P1: xidusn, P2:xidslt, P3:xidsqn
--'Logical Standby Terminal Apply',-- Class: Other, P1: stage, P2:, P3:
--'LogMiner: client waiting for transaction',-- Class: Idle, P1: , P2:, P3:
--'LogMiner: reader waiting for more redo',-- Class: Idle, P1: Session ID, P2:Thread, P3:Sequence
--'LogMiner: slave waiting for activate message',-- Class: Idle, P1: , P2:, P3:
--'LogMiner: wakeup event for builder',-- Class: Idle, P1: , P2:, P3:
--'LogMiner: wakeup event for preparer',-- Class: Idle, P1: , P2:, P3:
--'LogMiner: wakeup event for reader',-- Class: Idle, P1: , P2:, P3:
--'logout restrictor',-- Class: Concurrency, P1: , P2:, P3:
--'L1 validation',-- Class: Other, P1: seghdr, P2:l1bmb, P3:
--'master exit',-- Class: Other, P1: alive slaves, P2:, P3:
--'MMON (Lite) shutdown',-- Class: Other, P1: process#, P2:waited, P3:
--'MMON slave messages',-- Class: Other, P1: , P2:, P3:
--'MRP wait on archivelog archival',-- Class: Other, P1: , P2:, P3:
--'MRP wait on archivelog arrival',-- Class: Other, P1: , P2:, P3:
--'MRP wait on archivelog delay',-- Class: Other, P1: , P2:, P3:
--'MRP wait on process death',-- Class: Other, P1: , P2:, P3:
--'MRP wait on process restart',-- Class: Other, P1: , P2:, P3:
--'MRP wait on process start',-- Class: Other, P1: , P2:, P3:
--'MRP wait on startup clear',-- Class: Other, P1: , P2:, P3:
--'MRP wait on state change',-- Class: Other, P1: , P2:, P3:
--'MRP wait on state n_a',-- Class: Other, P1: , P2:, P3:
--'MRP wait on state reset',-- Class: Other, P1: , P2:, P3:
--'multiple dbwriter suspend/resume for file offline',-- Class: Administrative, P1: , P2:, P3:
--'name-service call wait',-- Class: Other, P1: waittime, P2:, P3:
--'no free buffers',-- Class: Other, P1: group#, P2:obj#, P3:block#
--'no free locks',-- Class: Other, P1: , P2:, P3:
--'null event',-- Class: Other, P1: , P2:, P3:
--'OLAP Aggregate Client Deq',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Aggregate Client Enq',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Aggregate Master Deq',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Aggregate Master Enq',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Null PQ Reason',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Parallel Temp Grew',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Parallel Temp Grow Request',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Parallel Temp Grow Wait',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'OLAP Parallel Type Deq',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'opishd',-- Class: Other, P1: , P2:, P3:
--'optimizer stats update retry',-- Class: Other, P1: , P2:, P3:
--'os thread startup',-- Class: Concurrency, P1: , P2:, P3:
--'parallel recovery coordinator waits for cleanup of slaves',-- Class: Idle, P1: , P2:, P3:
--'pending global transaction(s)',-- Class: Other, P1: scans, P2:, P3:
--'pi renounce write complete',-- Class: Cluster, P1: file#, P2:block#, P3:
--'pipe get',-- Class: Idle, P1: handle address, P2:buffer length, P3:timeout
--'pipe put',-- Class: Concurrency, P1: handle address, P2:record length, P3:timeout
--'PL/SQL lock timer',-- Class: Idle, P1: duration, P2:, P3:
--'pmon timer',-- Class: Idle, P1: duration, P2:, P3:
--'PMON to cleanup pseudo-branches at svc stop time',-- Class: Other, P1: , P2:, P3:
--'prewarm transfer retry',-- Class: Other, P1: , P2:, P3:
--'prior spawner clean up',-- Class: Other, P1: process_pid, P2:process_sno, P3:
--'process shutdown',-- Class: Other, P1: type, P2:process#, P3:waited
--'process startup',-- Class: Other, P1: type, P2:process#, P3:waited
--'process terminate',-- Class: Other, P1: , P2:, P3:
'PX create server',-- Class: Other, P1: nservers, P2:sleeptime, P3:enqueue
'PX Deq Credit: free buffer',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:qref
'PX Deq Credit: need buffer',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:qref
'PX Deq Credit: send blkd',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:qref
'PX Deq: Execute Reply',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Execution Msg',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Index Merge Close',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Index Merge Execute',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Index Merge Reply',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Join ACK',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: kdcphc_ack',-- Class: Idle, P1: kdcphc_ack, P2:, P3:
'PX Deq: kdcph_mai',-- Class: Idle, P1: kdcph_mai, P2:, P3:
'PX Deq: Msg Fragment',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: OLAP Update Close',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: OLAP Update Execute',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: OLAP Update Reply',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Par Recov Change Vector',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Par Recov Execute',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Par Recov Reply',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Parse Reply',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: reap credit',-- Class: Other, P1: , P2:, P3:
'PX Deq: Signal ACK',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Table Q Close',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Table Q Get Keys',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Table Q Normal',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Table Q qref',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Table Q Sample',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Test for msg',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Txn Recovery Reply',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deq: Txn Recovery Start',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Deque wait',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Idle Wait',-- Class: Idle, P1: sleeptime/senderid, P2:passes, P3:
'PX Nsq: PQ descriptor query',-- Class: Other, P1: , P2:, P3:
'PX Nsq: PQ load info query',-- Class: Other, P1: , P2:, P3:
'PX qref latch',-- Class: Other, P1: function, P2:sleeptime, P3:qref
'PX Send Wait',-- Class: Other, P1: , P2:, P3:
'PX server shutdown',-- Class: Other, P1: nalive, P2:sleeptime, P3:loop
'PX signal server',-- Class: Other, P1: serial, P2:error, P3:nbusy
'PX slave connection',-- Class: Other, P1: , P2:, P3:
'PX slave release',-- Class: Other, P1: , P2:, P3:
--'qerex_gdml',-- Class: Other, P1: , P2:, P3:
--'queue slave messages',-- Class: Other, P1: , P2:, P3:
--'rdbms ipc message',-- Class: Idle, P1: timeout, P2:, P3:
--'rdbms ipc message block',-- Class: Other, P1: , P2:, P3:
--'rdbms ipc reply',-- Class: Other, P1: from_process, P2:timeout, P3:
'read by other session',-- Class: User I/O, P1: file#, P2:block#, P3:class#
--'recovery area: computing applied logs',-- Class: Other, P1: , P2:, P3:
--'recovery area: computing backed up files',-- Class: Other, P1: , P2:, P3:
--'recovery area: computing dropped files',-- Class: Other, P1: , P2:, P3:
--'recovery area: computing identical files',-- Class: Other, P1: , P2:, P3:
--'recovery area: computing obsolete files',-- Class: Other, P1: , P2:, P3:
--'recovery read',-- Class: System I/O, P1: , P2:, P3:
--'reliable message',-- Class: Other, P1: channel context, P2:channel handle, P3:broadcast message
--'Replication Dequeue ',-- Class: Other, P1: sleeptime/senderid, P2:passes, P3:
--'resmgr:become active',-- Class: Scheduler, P1: location, P2: , P3: 
--'resmgr:cpu quantum',-- Class: Scheduler, P1: location, P2: , P3: 
--'resmgr:internal state change',-- Class: Concurrency, P1: location, P2: , P3: 
--'resmgr:internal state cleanup',-- Class: Concurrency, P1: location, P2: , P3: 
--'resmgr:sessions to exit',-- Class: Concurrency, P1: location, P2: , P3: 
--'retry contact SCN lock master',-- Class: Cluster, P1: , P2:, P3:
--'RF - FSFO Wait for Ack',-- Class: Other, P1: , P2:, P3:
--'rfi_drcx_site_del',-- Class: Other, P1: DRCX waiting for site to delete metadata, P2:, P3:
--'rfi_insv_shut',-- Class: Other, P1: wait for INSV to shutdown, P2:, P3:
--'rfi_insv_start',-- Class: Other, P1: wait for INSV to start, P2:, P3:
--'rfi_nsv_deldef',-- Class: Other, P1: NSVx to defer delete response message post to DMON, P2:, P3:
--'rfi_nsv_md_close',-- Class: Other, P1: NSVx metadata file close wait, P2:, P3:
--'rfi_nsv_md_write',-- Class: Other, P1: NSVx metadata file write wait, P2:, P3:
--'rfi_nsv_postdef',-- Class: Other, P1: NSVx to defer message post to DMON, P2:, P3:
--'rfi_nsv_shut',-- Class: Other, P1: wait for NSVx to shutdown, P2:, P3:
--'rfi_nsv_start',-- Class: Other, P1: wait for NSVx to start, P2:, P3:
--'rfi_recon1',-- Class: Other, P1: letting site register with its local listener before connect ret, P2:, P3:
--'rfi_recon2',-- Class: Other, P1: retrying connection for sending to remote DRCX, P2:, P3:
--'rfm_dmon_last_gasp',-- Class: Other, P1: DMON waiting on the last gasp event, P2:, P3:
--'rfm_dmon_pdefer',-- Class: Other, P1: DMON phase deferral wait, P2:, P3:
--'rfm_dmon_shut',-- Class: Other, P1: wait for DMON to shutdown, P2:, P3:
--'rfm_dmon_timeout_op',-- Class: Other, P1: DMON waiting to timeout an operation, P2:, P3:
--'rfm_pmon_dso_stall',-- Class: Other, P1: PMON delete state object stall, P2:, P3:
--'rfrdb_dbop',-- Class: Other, P1: waiting for database to be opened, P2:, P3:
--'rfrdb_recon1',-- Class: Other, P1: reconnecting back to new primary site during standby viability c, P2:, P3:
--'rfrdb_recon2',-- Class: Other, P1: waiting for standby database to be mounted, P2:, P3:
--'rfrdb_try235',-- Class: Other, P1: waiting for retrying the query to mask ORA-235 error, P2:, P3:
--'rfrla_lapp1',-- Class: Other, P1: waiting for logical apply engine to initialize, P2:, P3:
--'rfrla_lapp2',-- Class: Other, P1: checking for logical apply engine run-down progress, P2:, P3:
--'rfrla_lapp3',-- Class: Other, P1: waiting for new primary to initialize tables, P2:, P3:
--'rfrla_lapp4',-- Class: Other, P1: waiting for v$logstdby_stats view to be initialized, P2:, P3:
--'rfrla_lapp5',-- Class: Other, P1: waiting to reconnect to primary that is in BUILD_UP, P2:, P3:
--'rfrld_rhmrpwait',-- Class: Other, P1: waiting for MRP0 to stop while reinstating old primary to logica, P2:, P3:
--'rfrm_dbcl',-- Class: Other, P1: RSM notifier: waiting for sql latch on db close, P2:, P3:
--'rfrm_dbop',-- Class: Other, P1: RSM notifier: waiting for sql latch on db open, P2:, P3:
--'rfrm_nonzero_sub_count',-- Class: Other, P1: wait for subscriber count to become nonzero, P2:, P3:
--'rfrm_rsm_shut',-- Class: Other, P1: wait for RSMx processes to shutdown, P2:, P3:
--'rfrm_rsm_so_attach',-- Class: Other, P1: wait for RSMx to attach to state object, P2:, P3:
--'rfrm_rsm_start',-- Class: Other, P1: wait for RSMx processes to start, P2:, P3:
--'rfrm_stall',-- Class: Other, P1: RSM stall due to event RSM_STALL, P2:, P3:
--'rfrm_zero_sub_count',-- Class: Other, P1: wait for subscriber count to become zero, P2:, P3:
--'rfrpa_mrpdn',-- Class: Other, P1: waiting for MRP0 to stop while bringing physical apply engine of, P2:, P3:
--'rfrpa_mrpup',-- Class: Other, P1: waiting for MRP0 to start while bringing physical apply engine o, P2:, P3:
--'rfrxptarcurlog',-- Class: Other, P1: waiting for logical apply engine to finish initialization, P2:, P3:
--'rfrxpt_pdl',-- Class: Other, P1: waiting for retrying potential dataloss calculation before switc, P2:, P3:
--'RFS announce',-- Class: Other, P1: , P2:, P3:
--'RFS attach',-- Class: Other, P1: , P2:, P3:
--'RFS close',-- Class: Other, P1: , P2:, P3:
--'RFS create',-- Class: Other, P1: , P2:, P3:
--'RFS detach',-- Class: Other, P1: , P2:, P3:
--'RFS dispatch',-- Class: Other, P1: , P2:, P3:
--'RFS ping',-- Class: Other, P1: , P2:, P3:
--'RFS random i/o',-- Class: System I/O, P1: , P2:, P3:
--'RFS register',-- Class: Other, P1: , P2:, P3:
--'RFS sequential i/o',-- Class: System I/O, P1: , P2:, P3:
--'RFS write',-- Class: System I/O, P1: , P2:, P3:
'RMAN backup & recovery I/O',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'rollback operations active',-- Class: Other, P1: operation count, P2:, P3:
--'rollback operations block full',-- Class: Other, P1: max operations, P2:, P3:
--'rolling migration: cluster quiesce',-- Class: Other, P1: location, P2:waits, P3:
--'row cache lock',-- Class: Concurrency, P1: cache id, P2:mode, P3:request
--'row cache read',-- Class: Concurrency, P1: cache id, P2:address, P3:times
--'RVWR wait for flashback copy',-- Class: Other, P1: copy latch #, P2:, P3:
--'scginq AST call',-- Class: Other, P1: , P2:, P3:
--'secondary event',-- Class: Other, P1: event #, P2:wait time, P3:
--'select wait',-- Class: Other, P1: , P2:, P3:
--'set director factor wait',-- Class: Other, P1: , P2:, P3:
--'SGA: allocation forcing component growth',-- Class: Other, P1: , P2:, P3:
--'SGA: MMAN sleep for component shrink',-- Class: Idle, P1: component id, P2:current size, P3:target size
--'SGA: sga_target resize',-- Class: Other, P1: , P2:, P3:
--'simulated log write delay',-- Class: Other, P1: , P2:, P3:
--'single-task message',-- Class: Idle, P1: , P2:, P3:
--'slave exit',-- Class: Other, P1: nalive, P2:sleeptime, P3:loop
--'smon timer',-- Class: Idle, P1: sleep time, P2:failed, P3:
--'sort segment request',-- Class: Configuration, P1: , P2:, P3:
'SQL*Net break/reset to client',-- Class: Application, P1: driver id, P2:break?, P3:
'SQL*Net break/reset to dblink',-- Class: Application, P1: driver id, P2:break?, P3:
'SQL*Net message from client',-- Class: Idle, P1: driver id, P2:#bytes, P3:
'SQL*Net message from dblink',-- Class: Idle, P1: driver id, P2:#bytes, P3:
'SQL*Net message to client',-- Class: Network, P1: driver id, P2:#bytes, P3:
'SQL*Net message to dblink',-- Class: Network, P1: driver id, P2:#bytes, P3:
'SQL*Net more data from client',-- Class: Network, P1: driver id, P2:#bytes, P3:
'SQL*Net more data from dblink',-- Class: Network, P1: driver id, P2:#bytes, P3:
'SQL*Net more data to client',-- Class: Network, P1: driver id, P2:#bytes, P3:
'SQL*Net more data to dblink',-- Class: Network, P1: driver id, P2:#bytes, P3:
--'Standby redo I/O',-- Class: System I/O, P1: count, P2:intr, P3:timeout
--'statement suspended, wait error to be cleared',-- Class: Configuration, P1: , P2:, P3:
--'Streams: apply reader waiting for DDL to apply',-- Class: Application, P1: sleep time, P2:, P3:
'Streams AQ: deallocate messages from Streams Pool',-- Class: Idle, P1: , P2:, P3:
'Streams AQ: delete acknowledged messages',-- Class: Idle, P1: , P2:, P3:
'Streams AQ: enqueue blocked due to flow control',-- Class: Other, P1: , P2:, P3:
'Streams AQ: enqueue blocked on low memory',-- Class: Configuration, P1: , P2:, P3:
'Streams AQ: qmn coordinator idle wait',-- Class: Idle, P1: , P2:, P3:
'Streams AQ: qmn coordinator waiting for slave to start',-- Class: Other, P1: , P2:, P3:
'Streams AQ: qmn slave idle wait',-- Class: Idle, P1: , P2:, P3:
'Streams AQ: QueueTable kgl locks',-- Class: Other, P1: , P2:, P3:
'Streams AQ: RAC qmn coordinator idle wait',-- Class: Idle, P1: , P2:, P3:
'Streams AQ: waiting for busy instance for instance_name',-- Class: Other, P1: where, P2:wait_count, P3:
'Streams AQ: waiting for messages in the queue',-- Class: Idle, P1: queue id, P2:process#, P3:wait time
'Streams AQ: waiting for time management or cleanup tasks',-- Class: Idle, P1: , P2:, P3:
--'Streams capture: filter callback waiting for ruleset',-- Class: Application, P1: , P2:, P3:
--'Streams capture: resolve low memory condition',-- Class: Configuration, P1: , P2:, P3:
--'Streams capture: waiting for archive log',-- Class: Other, P1: , P2:, P3:
--'Streams capture: waiting for database startup',-- Class: Other, P1: , P2:, P3:
--'Streams capture: waiting for subscribers to catch up',-- Class: Configuration, P1: , P2:, P3:
--'Streams fetch slave: waiting for txns',-- Class: Idle, P1: , P2:, P3:
--'Streams miscellaneous event',-- Class: Other, P1: TYPE, P2:, P3:
--'Streams: RAC waiting for inter instance ack',-- Class: Cluster, P1: , P2:, P3:
--'switch logfile command',-- Class: Administrative, P1: , P2:, P3:
--'switch undo - offline',-- Class: Administrative, P1: , P2:, P3:
--'Sync ASM rebalance',-- Class: Other, P1: , P2:, P3:
'TCP Socket (KGAS)',-- Class: Network, P1:  , P2: , P3: 
--'test long ops',-- Class: Other, P1: , P2:, P3:
--'TEXT: URL_DATASTORE network wait',-- Class: Network, P1: , P2:, P3:
--'timer in sksawat',-- Class: Other, P1: , P2:, P3:
--'transaction',-- Class: Other, P1: undo seg#|slot#, P2:wrap#, P3:count
--'tsm with timeout',-- Class: Other, P1: , P2:, P3:
--'txn to complete',-- Class: Other, P1: , P2:, P3:
--'unbound tx',-- Class: Other, P1: , P2:, P3:
--'undo segment extension',-- Class: Configuration, P1: segment#, P2:, P3:
--'undo segment recovery',-- Class: Other, P1: segment#, P2:tx flags, P3:
--'undo segment tx slot',-- Class: Configuration, P1: segment#, P2:, P3:
--'undo_retention publish retry',-- Class: Other, P1: where, P2:retry_count, P3:
--'unspecified wait event',-- Class: Other, P1: , P2:, P3:
--'virtual circuit status',-- Class: Idle, P1: circuit#, P2:status, P3:
--'wait active processes',-- Class: Other, P1: , P2:, P3:
--'wait for a paralle reco to abort',-- Class: Other, P1: , P2:, P3:
--'wait for a undo record',-- Class: Other, P1: , P2:, P3:
--'wait for another txn - rollback to savepoint',-- Class: Other, P1: , P2:, P3:
--'wait for another txn - txn abort',-- Class: Other, P1: , P2:, P3:
--'wait for another txn - undo rcv abort',-- Class: Other, P1: , P2:, P3:
--'wait for assert messages to be sent',-- Class: Other, P1: , P2:, P3:
--'wait for change',-- Class: Other, P1: , P2:, P3:
--'wait for EMON to die',-- Class: Other, P1: , P2:, P3:
--'wait for EMON to process ntfns',-- Class: Configuration, P1: , P2:, P3:
--'wait for EMON to spawn',-- Class: Other, P1: , P2:, P3:
--'wait for FMON to come up',-- Class: Other, P1: , P2:, P3:
--'wait for master scn',-- Class: Other, P1: waittime, P2:startscn, P3:ackscn
--'wait for membership synchronization',-- Class: Other, P1: , P2:, P3:
--'wait for message ack',-- Class: Other, P1: , P2:, P3:
--'wait for MTTR advisory state object',-- Class: Other, P1: , P2:, P3:
--'wait for possible quiesce finish',-- Class: Administrative, P1: , P2:, P3:
--'wait for record update',-- Class: Other, P1: , P2:, P3:
--'wait for rr lock release',-- Class: Other, P1: , P2:, P3:
--'wait for scn ack',-- Class: Other, P1: pending_nd, P2:scnwrp, P3:scnbas
--'Wait for shrink lock',-- Class: Other, P1: object_id, P2:lock_mode, P3:
--'Wait for shrink lock2',-- Class: Other, P1: object_id, P2:lock_mode, P3:
--'wait for split-brain resolution',-- Class: Other, P1: , P2:, P3:
--'wait for stopper event to be increased',-- Class: Other, P1: , P2:, P3:
--'wait for sync ack',-- Class: Other, P1: cluinc, P2:pending_nd, P3:
--'Wait for Table Lock',-- Class: Application, P1: , P2:, P3:
--'wait for tmc2 to complete',-- Class: Other, P1: , P2:, P3:
--'Wait for TT enqueue',-- Class: Other, P1: tsn, P2:, P3:
--'wait for unread message on broadcast channel',-- Class: Idle, P1: channel context, P2:channel handle, P3:
--'wait for unread message on multiple broadcast channels',-- Class: Idle, P1: channel context, P2:channel handle count, P3:
--'wait for verification ack',-- Class: Other, P1: cluinc, P2:pending_insts, P3:
--'wait for votes',-- Class: Other, P1: , P2:, P3:
--'wait list latch activity',-- Class: Other, P1: address, P2:number, P3:process#
--'wait list latch free',-- Class: Other, P1: address, P2:number, P3:tries
--'Wait on stby instance close',-- Class: Other, P1: , P2:, P3:
--'waiting to get CAS latch',-- Class: Other, P1:  , P2: , P3: 
--'waiting to get RM CAS latch',-- Class: Other, P1:  , P2: , P3: 
--'watchdog main loop',-- Class: Idle, P1: , P2:, P3:
--'WCR: RAC message context busy',-- Class: Other, P1: , P2:, P3:
--'write complete waits',-- Class: Configuration, P1: file#, P2:block#, P3:
--'writes stopped by instance recovery or database suspension',-- Class: Other, P1: by thread#, P2:our thread#, P3:
--'xdb schema cache initialization',-- Class: Other, P1: , P2:, P3:
'---END OF EVENTS'
)
">
--and e.event_name not like 'enq:%' and e.event_name not like 'latch:%'
--and ash.program not like 'oracle@srv-bis_x (J___)'
--and ash.program not like 'rman%'
order by ash.sample_time
