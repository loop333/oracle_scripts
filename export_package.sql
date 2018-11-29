set define on
set heading off
set verify off
set serveroutput off
set pause off
set feedback off
set time off
set linesize 2000
set pagesize 0
set trimspool on
set echo off
set termout off

spool "&1..&2..PKG"

select 'CREATE OR REPLACE' from dual
/
select text from dba_source
where type = 'PACKAGE' and owner = '&1' and name = '&2'
order by line
/
select '/' from dual
/
select 'CREATE OR REPLACE' from dual
/
select text from dba_source
where type = 'PACKAGE BODY' and owner = '&1' and name = '&2'
order by line
/
select '/' from dual
/

spool off 

quit
