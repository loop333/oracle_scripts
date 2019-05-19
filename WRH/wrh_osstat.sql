with param as
(
 select to_date('19.05.2019 06:30:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time, osn.stat_name, oss.value
from
 param p, sys.wrm$_snapshot s, sys.wrh$_osstat oss, sys.wrh$_osstat_name osn
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and oss.dbid = s.dbid and oss.instance_number = s.instance_number and oss.snap_id = s.snap_id
 and osn.dbid = oss.dbid and osn.stat_id = oss.stat_id
 and osn.stat_name = 'LOAD'
order by
 s.begin_interval_time

--NUM_CPUS
--IDLE_TIME
--BUSY_TIME
--USER_TIME
--SYS_TIME
--IOWAIT_TIME
--NICE_TIME
--RSRC_MGR_CPU_WAIT_TIME
--LOAD
--NUM_CPU_CORES
--NUM_CPU_SOCKETS
--VM_IN_BYTES
--VM_OUT_BYTES
--TCP_SEND_SIZE_MIN
--TCP_SEND_SIZE_DEFAULT
--TCP_SEND_SIZE_MAX
--TCP_RECEIVE_SIZE_MIN
--TCP_RECEIVE_SIZE_DEFAULT
--TCP_RECEIVE_SIZE_MAX
--GLOBAL_SEND_SIZE_MAX
--GLOBAL_RECEIVE_SIZE_MAX
