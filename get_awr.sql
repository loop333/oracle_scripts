define db_str = 'db';
define instance_str = 'inst';
define begin_time = '31.12.2008 12:00:00';
define end_time = '31.12.2008 12:30:00';
define report_name = 'c:\1.html';

connect user/pass@db

column my_instance new_value my_instance noprint;
column my_db new_value my_db noprint;
column my_snap_begin new_value my_snap_begin noprint;
column my_snap_end new_value my_snap_end noprint;

select inst_id my_instance from gv$instance where instance_name = '&&instance_str';

select dbid my_db from gv$database where db_unique_name = '&&db_str' and inst_id = &my_instance;

select max(snap_id) my_snap_begin from dba_hist_snapshot where dbid = &my_db and instance_number = &my_instance and begin_interval_time < to_date('&&begin_time','DD.MM.YYYY HH24:MI:SS');

select min(snap_id) my_snap_end from dba_hist_snapshot where dbid = &my_db and instance_number = &my_instance and end_interval_time > to_date('&&end_time','DD.MM.YYYY HH24:MI:SS');

set heading off;
set echo off;
set linesize 1500;
set termout off;

spool &report_name;

select * from table (dbms_workload_repository.awr_report_html(&my_db,&my_instance,&my_snap_begin,&my_snap_end));

spool off;

quit;
