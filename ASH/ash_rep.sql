connect username/password@db

set heading off;
set termout off;
set feedback off;
set verify off;
set echo off;
set linesize 1500;

select
 output
from
 table(dbms_workload_repository.ash_report_text((select dbid from v$database),2,sysdate-30/24/60,sysdate-1/24/60))
