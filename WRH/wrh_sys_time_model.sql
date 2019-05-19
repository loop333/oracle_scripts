with param as
(
 select to_date('19.05.2019 06:00:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time t,
 sn.stat_name s,
 (stm2.value-stm1.value) v
from
 param p, sys.wrm$_snapshot s, sys.wrh$_sys_time_model stm1, sys.wrh$_sys_time_model stm2, sys.wrh$_stat_name sn
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and stm1.dbid = s.dbid and stm1.instance_number = s.instance_number and stm1.snap_id = s.snap_id-1
 and stm2.dbid = s.dbid and stm2.instance_number = s.instance_number and stm2.snap_id = s.snap_id
 and sn.dbid = stm1.dbid and sn.stat_id = stm1.stat_id
 and sn.dbid = stm2.dbid and sn.stat_id = stm2.stat_id
 and sn.stat_name = 'DB time'
order by
 s.begin_interval_time, sn.stat_id

/*
hard parse (bind mismatch) elapsed time
inbound PL/SQL rpc elapsed time
hard parse elapsed time
Java execution elapsed time
repeated bind elapsed time
PL/SQL compilation elapsed time
parse time elapsed
failed parse elapsed time
connection management call elapsed time
RMAN cpu time (backup/restore)
background cpu time
PL/SQL execution elapsed time
DB CPU
sql execute elapsed time
hard parse (sharing criteria) elapsed time
DB time
failed parse (out of shared memory) elapsed time
sequence load elapsed time
background elapsed time
*/
