with
param as
(
 select to_date('07.04.2016 03:05:00','DD.MM.YYYY HH24:MI:SS') begin_date,
        to_date('07.04.2016 04:15:00','DD.MM.YYYY HH24:MI:SS') end_date
 from dual
)
select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
 ash.instance_number, machine, count(*)
from param p, sys.wrm$_snapshot snap, sys.wrh$_active_session_history ash
where snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
and ash.dbid = (select dbid from gv$database where rownum = 1) and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number
and ash.sample_time between p.begin_date and p.end_date
group by ash.instance_number, machine
order by machine

 
