--select * from dba_jobs

begin
for c in (
select sid, serial# from gv$session s, dba_procedures p where program like '%PRG_NAME%'
and p.object_id = s.plsql_entry_object_id and p.subprogram_id = s.plsql_entry_subprogram_id
and p.procedure_name = 'PROC_NAME') loop
 execute immediate 'alter system kill session '''||c.sid||','||c.serial#||''' immediate';
end loop;
end

begin
for c in (select sid, serial# from gv$session s where s.user# = 0 and s.machine like 'machine%') loop
 execute immediate 'alter system kill session '''||c.sid||','||c.serial#||''' immediate';
-- null;
end loop;
end;


select
--*
'alter system kill session '''||sid || ',' || serial# || ''' immediate'
from gv$session s, dba_procedures p
where
 1=1
-- and program like '%(J%'
 and upper(program) like '%PRG_NAME%'
 and p.object_id (+) = s.plsql_entry_object_id and p.subprogram_id (+) = s.plsql_entry_subprogram_id
--and p.procedure_name = 'RROC_NAME'
