with param as
(
 select to_date('19.05.2019 06:30:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time t, stn.stat_name s, (ss2.value-ss1.value) v
from
 param p, sys.wrm$_snapshot s, sys.wrh$_service_stat ss1, sys.wrh$_service_stat ss2, sys.wrh$_service_name sn, sys.wrh$_stat_name stn
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and ss1.dbid = s.dbid and ss1.instance_number = s.instance_number and ss1.snap_id = s.snap_id-1
 and ss1.service_name_hash = sn.service_name_hash and ss1.stat_id = stn.stat_id
 and ss2.dbid = s.dbid and ss2.instance_number = s.instance_number and ss2.snap_id = s.snap_id
 and ss2.service_name_hash = sn.service_name_hash and ss2.stat_id = stn.stat_id
 and sn.dbid = s.dbid
 and stn.dbid = s.dbid
 and sn.service_name = 'CCB'
-- and sn.service_name = 'SYS$USERS'
-- and sn.service_name = 'SYS$BACKGROUND'
-- and stn.stat_name = 'DB time'
 and stn.stat_name = 'user commits'
order by
 s.begin_interval_time

--workarea executions - optimal
--session logical reads
--DB time
--user rollbacks
--session cursor cache hits
--workarea executions - multipass
--concurrency wait time
--parse count (total)
--opened cursors cumulative
--gc current blocks received
--user commits
--workarea executions - onepass
--db block changes
--application wait time
--physical writes
--redo size
--gc current block receive time
--parse time elapsed
--gc cr block receive time
--physical reads
--cluster wait time
--execute count
--logons cumulative
--DB CPU
--sql execute elapsed time
--gc cr blocks received
--user calls
--user I/O wait time
