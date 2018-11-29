with
param as
(
 select to_date('22.04.2015 10:10:00','DD.MM.YYYY HH24:MI:SS') begin_date,
        to_date('22.04.2015 10:27:00','DD.MM.YYYY HH24:MI:SS') end_date
 from dual
)
select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
 ash.instance_number,
 ash.sql_id,
 sum(nvl(ash.delta_read_io_bytes,0)+nvl(ash.delta_write_io_bytes,0))
from
 param p, sys.wrm$_snapshot snap, sys.wrh$_active_session_history ash
where
 snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
 and ash.dbid = (select dbid from gv$database where rownum = 1) and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number
 and ash.sample_time between p.begin_date and p.end_date
group by ash.instance_number, ash.sql_id
order by 3 desc

with
param as
(
 select to_date('22.04.2015 10:10:00','DD.MM.YYYY HH24:MI:SS') begin_date,
        to_date('22.04.2015 10:27:00','DD.MM.YYYY HH24:MI:SS') end_date
 from dual
)
select
 ss.instance_number,
 ss.plan_hash_value,
 sum(ss.physical_read_bytes_delta+ss.physical_write_bytes_delta)
from
 param p, sys.wrm$_snapshot snap, sys.wrh$_sqlstat ss
where
 snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
 and ss.dbid = (select dbid from gv$database where rownum = 1) and ss.snap_id = snap.snap_id and ss.instance_number = snap.instance_number
group by ss.instance_number, ss.plan_hash_value
order by 3 desc

select * from gv$sql s where s.plan_hash_value = 3711188860
