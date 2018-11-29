with
param as (select to_date('01.03.2015 00:00:00','DD.MM.YYYY HH24:MI:SS') date_begin,
                 to_date('01.04.2015 00:00:00','DD.MM.YYYY HH24:MI:SS') date_end,
                 1/24/60                                                date_step
                 from dual),
scale as (select
           param.date_begin+(level-1)*param.date_step date1,
           param.date_begin+level*param.date_step date2
          from dual, param
          connect by param.date_begin+(level-1)*param.date_step between param.date_begin and param.date_end)
select
 date1 d,
 (select /*+ index(sh WRH$_SYSMETRIC_HISTORY_INDEX) */
          sum(sh.value)
         from
          param, sys.wrm$_snapshot s, sys.wrh$_sysmetric_history sh, sys.wrh$_metric_name mn
         where 
          s.dbid = (select dbid from v$database) and s.instance_number in (1,2)
          and s.begin_interval_time <= date2 and s.end_interval_time >= date1 
          and mn.group_name = 'System Metrics Long Duration' and mn.metric_name = 'Redo Generated Per Sec'
          and sh.dbid = s.dbid and sh.instance_number = s.instance_number and sh.snap_id = s.snap_id
          and date1 <= sh.end_time and sh.end_time < date2
          and sh.metric_id = mn.metric_id and sh.group_id = mn.group_id) v         
from
 scale


/*
select * from sys.wrh$_metric_name mn where lower(metric_name) like '%write%byte%'

select distinct mn.group_name, mn.metric_name
from sys.wrh$_sysmetric_history sh, sys.wrh$_metric_name mn
where sh.begin_time > sysdate - 1 and mn.dbid = sh.dbid and mn.group_id = sh.group_id and mn.metric_id = sh.metric_id
and sh.value != 0
*/ 

with
param as (select to_date('09.02.2015 00:00:00','DD.MM.YYYY HH24:MI:SS') date_begin,
                 to_date('01.03.2015 00:00:00','DD.MM.YYYY HH24:MI:SS') date_end,
                 1/24/60                                                date_step
                 from dual),
scale as (select
           param.date_begin+(level-1)*param.date_step date1,
           param.date_begin+level*param.date_step date2
          from dual, param
          connect by param.date_begin+(level-1)*param.date_step between param.date_begin and param.date_end),
data as (select /*+ index(sh WRH$_SYSMETRIC_HISTORY_INDEX) */
          sh.end_time dt,
          sh.value
         from
          param, sys.wrm$_snapshot s, sys.wrh$_sysmetric_history sh, sys.wrh$_metric_name mn
         where 
          s.dbid = (select dbid from v$database) and s.instance_number in (1,2)
          and s.begin_interval_time <= param.date_end and s.end_interval_time >= param.date_begin 
          and mn.group_name = 'System Metrics Long Duration' and mn.metric_name = 'Redo Generated Per Sec'
          and sh.dbid = s.dbid and sh.instance_number = s.instance_number and sh.snap_id = s.snap_id
          and param.date_begin <= sh.end_time and sh.end_time < param.date_end
          and sh.metric_id = mn.metric_id and sh.group_id = mn.group_id)          
select
 date1 d,
 (select sum(value) from data where date1 <= dt and dt < date2) v
from
 scale
 
