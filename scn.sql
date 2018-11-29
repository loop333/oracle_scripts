with t1 as(
select time_dp , 24*60*60*(time_dp - lag(time_dp) over (order by time_dp)) timediff,
  scn - lag(scn) over(order by time_dp) scndiff
from sys.smon_scn_time
)
select time_dp , timediff, scndiff, trunc(scndiff/timediff) rate_per_sec
from t1
order by 1

select  thread#,  first_time, next_time, first_change# ,next_change#, sequence#,
   next_change#-first_change# diff, round ((next_change#-first_change#)/(next_time-first_time)/24/60/60) rt
from (
select thread#, first_time, first_change#,next_time,  next_change#, sequence#,dest_id from v$archived_log
where next_time > sysdate-30 and dest_id=1 and next_time != first_time
order by next_time
)
order by  first_time, thread#

select (sysdate-to_date('19880101','YYYYMMDD'))*24*60*60*16384 from dual
12979166265344
select (sysdate-to_date('19880101','YYYYMMDD'))*24*60*60*32768 from dual
25958336299008

select to_char(dbms_flashback.get_system_change_number,'xxxxxxxxxxxxxxxxxxxxxx'),dbms_flashback.get_system_change_number curscn from dual;
12986979462468
select dbms_flashback.get_system_change_number curscn from dual;

select
 a.ksppinm Param,
 b.ksppstvl SessionVal,
 c.ksppstvl InstanceVal,
 a.ksppdesc Descr
from
 x$ksppi a,
 x$ksppcv b,
 x$ksppsv c
where
 a.indx = b.indx
 and a.indx = c.indx
 and a.ksppinm = '_max_reasonable_scn_rate'

select 39086*power(2,32)+1454745734 from dual
167874546477190
select 42170*power(2,32)+386042016 from dual
181119156914336
select 3077*power(2,32)+1388068864 from dual
13217002438656

select * from gv$database_block_corruption


select
 dbms_utility.data_block_address_file(to_number('5d5127ac','xxxxxxxxxxxx')),
 dbms_utility.data_block_address_block(to_number('5d5127ac','xxxxxxxxxxxx'))
from dual
  
select * from dba_data_files where file_id = 373
select * from dba_extents where file_id = 373 and 1124268 between block_id and block_id + blocks - 1

   
