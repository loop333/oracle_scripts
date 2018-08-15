select
 hs.inst_id h_i, hs.sid h_sid, hs.serial# h_serial,
 hq.qcinst_id q_i, hq.qcsid q_sid, hq.qcserial# q_serial,
 round(h.ctime/60,1) h_time_min, round(w.ctime/60,1) w_time_min, hp.spid h_spid, hs.username h_name, hs.osuser h_os,
 hs.sql_id h_sql, hs.prev_sql_id h_psql, 
 hs.program h_prg, hs.machine h_machine, hs.client_info h_ci,
 hpr.owner || '.' || hpr.object_name || '.' || hpr.procedure_name h_prc, 
 h.type, lt.name,
 decode(h.lmode,
        0,'None',
        1,'Null',
        2,'Row-S',
        3,'Row-X',
        4,'Share',
        5,'Share Row-X',
        6,'Exclusive',
        'Unknown') h_mode,
 decode(w.request,
        0,'None',
        1,'Null',
        2,'Row-S',
        3,'Row-X',
        4,'Share',
        5,'Share Row-X',
        6,'Exclusive',
        'Unknown') w_mode,
        h.block, w.block,
 ws.inst_id w_i, ws.sid w_sid, ws.serial# w_serial, ws.username w_name, ws.osuser w_os, ws.program w_prg, ws.machine w_machine,
 wpr.owner || '.' || wpr.object_name || '.' || wpr.procedure_name w_prc, ws.client_info w_ci,
-- hs.*, ws.*
 case
  when h.type = 'TM' then (select owner||'.'||object_name from dba_objects where object_id = h.id1)
  when h.type = 'TQ' then (select owner||'.'||object_name from dba_objects where object_id = h.id1)
  when h.type = 'TO' then (select owner||'.'||object_name from dba_objects where object_id = h.id1)
  when h.type = 'TS' then (select owner||'.'||object_name from dba_objects where object_id = h.id1)
  when h.type = 'TX' then (select owner||'.'||object_name from dba_objects where object_id = ws.row_wait_obj#) || ' | ' ||
                          (select sql_text from gv$sql where sql_id = nvl(hs.sql_id,hs.prev_sql_id) and rownum = 1)
  when h.type = 'MR' then (select file_name from dba_data_files where file_id = h.id1)
  else 'UNKNOWN TYPE ' || h.type || ' ' || h.id1 || ',' || h.id2
 end info,
 'alter system kill session '''||hs.sid||','||hs.serial#||',@'||hs.inst_id||''' immediate' kill
from
 gv$lock w, gv$lock h, gv$session ws, gv$session hs, gv$lock_type lt, gv$process hp, dba_procedures wpr, dba_procedures hpr, gv$px_session hq
where
 w.request > 0 and h.lmode > 0
 and w.type = h.type and w.id1 = h.id1 and w.id2 = h.id2
 and hs.inst_id = h.inst_id and hs.sid = h.sid
 and ws.inst_id = w.inst_id and ws.sid = w.sid
 and lt.inst_id = h.inst_id and lt.type = h.type
 and hp.inst_id = hs.inst_id and hp.addr = hs.paddr
 and hpr.object_id (+) = hs.plsql_entry_object_id and hpr.subprogram_id (+) = hs.plsql_entry_subprogram_id
 and wpr.object_id (+) = ws.plsql_entry_object_id and wpr.subprogram_id (+) = ws.plsql_entry_subprogram_id
 and hq.inst_id (+) = h.inst_id and hq.sid (+) = h.sid 

--select * from gv$lock

--select * from gv$lock l, gv$locked_object lo
--where l.lmode > 0 and lo.inst_id (+) = l.inst_id and lo.session_id (+) = l.sid
--order by l.inst_id, l.sid, l.addr

--select * from gv$lock_type where type = 'TX'
--select * from gv$locked_object

--select distinct type from gv$lock

--select * from gv$lock_type where type = 'WL'

--3074201
--155441666

--select * from gv$queue
--select * from dba_objects where object_id = 3074201

/*
select * from gv$lock_type where inst_id = 2 and type in
(
'RS',
'RT',
'PS',
'TO',
'TX',
'UL',
'XR',
'DM',
'MR',
'TM',
'WL',
'DX',
'PW',
'JQ',
'TS',
'CF'
)
*/

--select * from gv$lock l, dba_data_files df where type = 'MR' and df.file_id = l.id1
--select * from gv$lock l, dba_objects o where type = 'TS' and o.object_id (+) = l.id1

--select * from gv$lock where lmode > 0 and type not in ('TX','TM','TO','TQ','TS','MR','JQ','DX','DM')

--select * from gv$lock l, gv$session s where l.lmode > 0 and l.type = 'DX' and s.inst_id = l.inst_id and s.sid = l.sid
--select * from gv$global_transaction
--select * from gv$global_blocked_locks
--select * from gv$transaction
--select * from sys.pending_trans$
--SELECT * from DBA_PENDING_TRANSACTIONS





