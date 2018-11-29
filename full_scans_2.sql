select * from gv$sql_plan where operation = 'TABLE ACCESS' and options = 'FULL'


select * from gv$fixed_view_definition fvd where fvd.VIEW_NAME like '%SQL_PLAN%'

select distinct operation, options from gv$sql_plan

'FIXED TABLE', 'FULL'
'INDEX', 'FULL SCAN'
'TABLE ACCESS', 'FULL'

select * from dba_tables

select * from 
(select distinct sql_id, child_number, object_owner, object_name from gv$sql_plan where operation = 'TABLE ACCESS' and options = 'FULL') sp,
dba_tables t, gv$sql s
where t.owner = sp.object_owner and t.table_name = sp.object_name 
and s.sql_id = sp.sql_id and s.child_number = sp.child_number and s.disk_reads > 0
order by t.blocks desc

select * from dba_segments where segment_name like 'CLIENT_HISTORIES'

select * from 
(select distinct sql_id, object_owner, object_name from gv$sql_plan where operation = 'TABLE ACCESS' and options = 'FULL') sp,
dba_segments s
where s.owner = sp.object_owner and s.segment_name = sp.object_name and s.segment_type = 'TABLE' 
order by s.blocks desc

select * from gv$sql

select * from dba_data_files

