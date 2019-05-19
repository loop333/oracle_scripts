with param as
(
 select to_date('19.05.2019 06:00:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 to_char(smh.begin_time, 'DD.MM.YYYY HH24:MI:SS') d,
 mn.metric_name s,
 smh.value v
from
 param p, sys.wrm$_snapshot s, sys.wrh$_sysmetric_history smh, sys.wrh$_metric_name mn
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and smh.dbid = s.dbid and smh.instance_number = s.instance_number and smh.snap_id = s.snap_id
 and smh.group_id = mn.group_id and smh.metric_id = mn.metric_id
 and mn.metric_name = 'Physical Reads Per Sec'
 and mn.group_name = 'System Metrics Long Duration'
-- and mn.group_name = 'System Metrics Short Duration'
order by 
 smh.begin_time

--DB Block Changes Per Txn
--Executions Per Sec
--Average Active Sessions
--Redo Generated Per Sec
--Redo Generated Per Txn
--Physical Writes Per Sec
--User Calls Per Sec
--Logical Reads Per Txn
--User Transaction Per Sec
--Physical Reads Per Sec
--Physical Reads Per Txn
--Logons Per Sec
