--select * from dba_segments order by bytes desc
--select min(start_time) from icinga.servicechecks

--delete from icinga.servicechecks where id < (select min(id)+5000 from icinga.servicechecks)

------------------------------------------------------------------------------------------------
declare
 l_object_id number;
begin
-- Create a segment advisor task for the table
 dbms_advisor.create_task(
    advisor_name => 'Segment Advisor',
    task_name    => 'TABLE_SEGMENT_ADVISOR',
    task_desc    => 'Segment Advisor For Table');

 dbms_advisor.create_object(
    task_name   => 'TABLE_SEGMENT_ADVISOR',
    object_type => 'TABLE',
    attr1       => 'ICINGA',
    attr2       => 'HOSTCHECKS',
    attr3       => NULL,
    attr4       => 'null',
    attr5       => NULL,
    object_id   => l_object_id);

 dbms_advisor.set_task_parameter(
    task_name => 'TABLE_SEGMENT_ADVISOR',
    parameter => 'RECOMMEND_ALL',
    value     => 'TRUE');

 dbms_advisor.execute_task(task_name => 'TABLE_SEGMENT_ADVISOR');
end;

begin
 dbms_advisor.delete_task(task_name => 'TABLE_SEGMENT_ADVISOR');
 dbms_advisor.delete_task(task_name => 'TABLESPACE_SEGMENT_ADVISOR');
end;

----------------------------------------------------------------------------------------------------
declare
 l_object_id number;
begin
-- Create a segment advisor task for the tablespace.
 dbms_advisor.create_task(
    advisor_name => 'Segment Advisor',
    task_name    => 'TABLESPACE_SEGMENT_ADVISOR',
    task_desc    => 'Segment Advisor For Tablespace');

 dbms_advisor.create_object(
    task_name   => 'TABLESPACE_SEGMENT_ADVISOR',
    object_type => 'TABLESPACE',
    attr1       => 'MONITOR',
    attr2       => NULL,
    attr3       => NULL,
    attr4       => 'null',
    attr5       => NULL,
    object_id   => l_object_id);

 dbms_advisor.set_task_parameter(
    task_name => 'TABLESPACE_SEGMENT_ADVISOR',
    parameter => 'RECOMMEND_ALL',
    value     => 'TRUE');

 dbms_advisor.execute_task(task_name => 'TABLESPACE_SEGMENT_ADVISOR');
end;

begin
 dbms_advisor.delete_task(task_name => 'TABLE_SEGMENT_ADVISOR');
 dbms_advisor.delete_task(task_name => 'TABLESPACE_SEGMENT_ADVISOR');
end;

-- Display the findings.
select f.task_name,
       f.impact,
       o.type object_type,
       o.attr1 schema,
       o.attr2 object_name,
       f.message,
       f.more_info
from dba_advisor_findings f
     join dba_advisor_objects o on f.object_id = o.object_id and f.task_name = o.task_name
where f.task_name in ('TABLE_SEGMENT_ADVISOR','TABLESPACE_SEGMENT_ADVISOR')
order by f.task_name, f.impact desc

--alter table icinga.servicechecks enable row movement
--alter table icinga.notifications enable row movement
--alter table icinga.hostchecks enable row movement
--alter table icinga.externalcommands enable row movement

--alter table icinga.notifications shrink space cascade
--alter table icinga.externalcommands shrink space cascade
--alter table icinga.servicechecks shrink space cascade
