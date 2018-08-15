with
param as
(
 select &<name="Begin" type="date"> begin_date,
        &<name="End" type="date"> end_date
 from dual
),
locks as
(
 select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
  u.username,
  ash.program,
  ash.session_id sid,
  ash.session_serial# serial,
  case
   when ash.blocking_session between 4294967291 and 4294967295 then 0
   else ash.blocking_session
  end b_sid,
  case
   when ash.blocking_session between 4294967291 and 4294967295 then 0
   else ash.blocking_session_serial#
  end b_serial,
  count(*)
 from
  param p, sys.wrm$_snapshot snap, sys.wrh$_active_session_history ash, dba_users u
 where
  snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
  and ash.dbid = 304481731 and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number
  and ash.sample_time between p.begin_date and p.end_date
  and u.user_id = ash.user_id
 group by  
  u.username,
  ash.program,
  ash.session_id,
  ash.session_serial#,
  case
   when ash.blocking_session between 4294967291 and 4294967295 then 0
   else ash.blocking_session
  end,
  case
   when ash.blocking_session between 4294967291 and 4294967295 then 0
   else ash.blocking_session_serial#
  end
)
select
 lpad(' ',2*(level - 1)) || username || ',' || program || ',' || sid || ',' || serial,
 connect_by_iscycle
from
(
select * from locks a
)
where connect_by_isleaf = 0 or level > 1
start with b_sid = 0 and b_serial = 0
connect by nocycle prior sid = b_sid and prior serial = b_serial and connect_by_iscycle = 0
