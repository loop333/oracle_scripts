with param as
(
 select to_date('19.05.2019 06:30:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select 
 s.begin_interval_time t,
-- sn.service_name s,
 swc.wait_class s,
 (wc2.total_waits-wc1.total_waits) v1,
 (wc2.time_waited-wc1.time_waited) v2
from
 param p, sys.wrm$_snapshot s, sys.wrh$_service_wait_class wc1, sys.wrh$_service_wait_class wc2, sys.wrh$_service_name sn, gv$system_wait_class swc
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and wc1.dbid = s.dbid and wc1.instance_number = s.instance_number and wc1.snap_id = s.snap_id-1
 and wc1.service_name_hash = sn.service_name_hash and wc1.wait_class_id = swc.wait_class_id
 and wc2.dbid = s.dbid and wc2.instance_number = s.instance_number and wc2.snap_id = s.snap_id
 and wc2.service_name_hash = sn.service_name_hash and wc2.wait_class_id = swc.wait_class_id
 and swc.wait_class = 'Application'
 and sn.dbid = s.dbid
 and sn.service_name = 'CCB'
order by
 s.begin_interval_time
