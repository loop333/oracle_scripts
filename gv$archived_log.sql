select l.blocks*l.block_size/1024/1024, l.*
from gv$archived_log l where recid > (select max(recid)-20 from gv$archived_log)
--and name = 'JANUARY'
order by recid, inst_id

select * from gv$loghist where sequence# = 361861


with
param as (select &<name="Begin" type="date" default="sysdate-1/24"> date_begin,
                 &<name="End" type="date" default="sysdate"> date_end,
                 to_number(&<name="Step" type="none" default="1/24/60">) date_step
                 from dual),
scale as (select
           param.date_begin+(level-1)*param.date_step date1,
           param.date_begin+level*param.date_step date2, 
           cast(from_tz(cast(param.date_begin+(level-1)*param.date_step as timestamp),'Asia/Yekaterinburg') at time zone 'UTC' as date) utc_date1,
           cast(from_tz(cast(param.date_begin+level*param.date_step as timestamp),'Asia/Yekaterinburg') at time zone 'UTC' as date) utc_date2 
          from dual, param
          connect by param.date_begin+(level-1)*param.date_step between param.date_begin and param.date_end)
select
 date1 "Date",
 (select sum(blocks*block_size/1024/1024) from gv$archived_log where date1 <= next_time and next_time < date2)
from
 scale

-- 
with 
param as (select &<name="Begin" type="date" default="sysdate-1/24"> date_begin,
                 &<name="End" type="date" default="sysdate"> date_end,
                 to_number(&<name="Step" type="none" default="1/24/60">) date_step
                 from dual),
scale as (select
           param.date_begin+(level-1)*param.date_step date1,
           param.date_begin+level*param.date_step date2, 
           cast(from_tz(cast(param.date_begin+(level-1)*param.date_step as timestamp),'Asia/Yekaterinburg') at time zone 'UTC' as date) utc_date1,
           cast(from_tz(cast(param.date_begin+level*param.date_step as timestamp),'Asia/Yekaterinburg') at time zone 'UTC' as date) utc_date2 
          from dual, param
          connect by param.date_begin+(level-1)*param.date_step between param.date_begin and param.date_end),
tmp as (select /*+ materialize */
          next_time t, blocks*block_size/1024/1024 d
         from gv$archived_log l, param
         where param.date_begin <= l.next_time and l.next_time < param.date_end
         and dest_id = 1 and inst_id = 2)
--         and l.name = 'JANUARY')
select
 date1 "Date",
 (select sum(d) from tmp where s.date1 <= t and t < s.date2)
from
 scale s

select * from dba_hist_log

 
with
param as
(
 select &<name="Begin" type="date"> begin_date,
        &<name="End" type="date"> end_date
 from dual
)
select
 snap.begin_interval_time,
 l.*,
 (select name from gv$archived_log al where al.sequence# = l.sequence# and al.inst_id = 2)
from param p, dba_hist_snapshot snap, dba_hist_log l
where
snap.begin_interval_time <= p.end_date and snap.end_interval_time >= p.begin_date
and l.dbid = (select dbid from gv$database where rownum = 1) and l.snap_id = snap.snap_id and l.instance_number = snap.instance_number
and p.begin_date <= l.first_time and l.first_time < p.end_date
order by l.first_time
 
