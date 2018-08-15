define db_str = 'db';
define instance_str = 'inst';
define begin_time = '21.08.2013 08:30:00';
define end_time = '21.08.2013 09:00:00';
define report_path = '.\';

connect username/password@db

set heading off;
set termout off;
set feedback off;
set verify off;
set echo off;
set linesize 1500;

variable my_instance   number;
variable my_dbid       number;
variable my_snap_begin number;
variable my_snap_end   number;

begin
 select inst_id into :my_instance from gv$instance where instance_name = '&instance_str';
 select dbid into :my_dbid from gv$database where db_unique_name = '&db_str' and inst_id = :my_instance;
 select max(snap_id) into :my_snap_begin from dba_hist_snapshot where dbid = :my_dbid and instance_number = :my_instance and begin_interval_time < to_date('&begin_time','DD.MM.YYYY HH24:MI:SS');
 select min(snap_id) into :my_snap_end from dba_hist_snapshot where dbid = :my_dbid and instance_number = :my_instance and end_interval_time > to_date('&end_time','DD.MM.YYYY HH24:MI:SS');
end;
/

column report_name new_value report_name;
select '&report_path'||'&instance_str'||'_'||:my_snap_begin||'_'||:my_snap_end||'.html' report_name from dual;

spool &report_name;
select * from table (dbms_workload_repository.awr_report_html(:my_dbid,:my_instance,:my_snap_begin,:my_snap_end));
spool off;

quit;
