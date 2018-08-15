select * from table (dbms_workload_repository.awr_report_text(
&<name="DB" list="select dbid, name from v$database" description="yes">,
&<name="Instance" list="select inst_id, instance_name from gv$instance order by instance_name" description="yes">,
&<name="Begin" list="select snap_id, to_char(end_interval_time,'DD.MM.YYYY HH24:MI') from dba_hist_snapshot where instance_number = :instance and begin_interval_time > sysdate-1 order by snap_id desc" description="yes">,
&<name="End" list="select snap_id, to_char(end_interval_time,'DD.MM.YYYY HH24:MI') from dba_hist_snapshot where instance_number = :instance and begin_interval_time > sysdate-1 order by snap_id desc" description="yes">
));

--select snap_id, to_char(begin_interval_time,'DD.MM.YYYY HH24:MI')||' - '||to_char(end_interval_time,'DD.MM.YYYY HH24:MI') from dba_hist_snapshot where begin_interval_time > sysdate - 1 order by snap_id

--select * from dba_hist_snapshot


SELECT * FROM TABLE (dbms_workload_repository.awr_report_test(
&<name="DB" list="select dbid, name from v$database" description="yes">,
&<name="Instance" list="select inst_id, instance_name from gv$instance order by instance_name" description="yes">,
&<name="Begin" list="select snap_id, to_char(end_interval_time,'DD.MM.YYYY HH24:MI') from dba_hist_snapshot where instance_number = :instance and begin_interval_time > sysdate-1 order by snap_id desc" description="yes">,
&<name="End" list="select snap_id, to_char(end_interval_time,'DD.MM.YYYY HH24:MI') from dba_hist_snapshot where instance_number = :instance and begin_interval_time > sysdate-1 order by snap_id desc" description="yes">));


