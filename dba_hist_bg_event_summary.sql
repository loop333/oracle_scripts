--select * from dba_hist_bg_event_summary -- snap_id, dbid, instance_number, event_name, wait_class, total_waits, time_waited_micro

with
param as (select &<name="Begin" type="date" default="sysdate-1"> date_begin,
                 &<name="End" type="date" default="sysdate"> date_end,
                 &<name="Max Value" type="float" default="10000000"> max_value,
                 &<name="Min Value" type="float" default="0"> min_value,
                 &<name="Instance" type="integer" default="2"> inst_id,
                 &<name="Wait" type="string" default="enq%"> wait_name
                 from dual)
select
 snap.begin_interval_time d,
 en.event_name,
 bes.total_waits tw
-- greatest(least(ss.value - lag(ss.value,1) over (partition by ss.dbid, ss.instance_number, ss.stat_id order by ss.snap_id),max_value),min_value) v
from
 param p, sys.wrm$_snapshot snap, sys.wrh$_bg_event_summary bes, sys.wrh$_event_name en
where
 snap.dbid = (select dbid from v$database)
 and snap.instance_number = p.inst_id
 and snap.begin_interval_time <= p.date_end and snap.end_interval_time >= p.date_begin
 and bes.dbid = snap.dbid and bes.snap_id = snap.snap_id and bes.instance_number = snap.instance_number
 and en.event_name like p.wait_name
 and bes.event_id = en.event_id
-- and ss.stat_id = (select stat_id from sys.wrh$_stat_name where stat_name = 'DB time')
order by snap.begin_interval_time
