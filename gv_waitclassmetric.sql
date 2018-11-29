select begin_time, wait_class#, (time_waited)/(intsize_csec/100)
from v$waitclassmetric
union all
select begin_time, -1, value
from v$sysmetric
where metric_name = 'CPU Usage Per Sec' and group_id = 2
order by begin_time, wait_class#

select * from gv$waitclassmetric
select * from gv$sysmetric
select * from gv$eventmetric

select * from gv$waitclassmetric_history where inst_id = 2 and wait_class# = 0 order by begin_time

select distinct group_id, metric_name from gv$sysmetric

select * from gv$system_wait_class

select wcm1.begin_time time, wcm1.time_waited bis2, wcm2.time_waited bis3
from gv$waitclassmetric_history wcm1, gv$waitclassmetric_history wcm2
where wcm1.inst_id = 2 and wcm2.inst_id = 3
      and wcm1.wait_class# = 0 and wcm2.wait_class# = 0
      and trunc(wcm1.begin_time,'MI') = trunc(wcm2.begin_time,'MI')
order by 1

select * from gv$waitclassmetric order by begin_time

select * from gv$waitclassmetric_history
