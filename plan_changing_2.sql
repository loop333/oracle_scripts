select 
 sql_id,
 snap_id,
 pplan,
 plan,
 pt,
 pc,
 t,
 c,
 pt/pc,
 t/c,
 (t/c-pt/pc)/(pt/pc)*100
from
(
with sql_stat as
 (select sql_id, plan_hash_value plan, snap_id, sum(executions_delta) c, sum(elapsed_time_delta) t
  from dba_hist_sqlstat
  where dbid = 304481731 and instance_number in (2,3) and snap_id > (select max(snap_id)-10 from dba_hist_snapshot)
  group by sql_id, plan_hash_value, snap_id) 
select
 sql_id,
 snap_id,
 plan,
 c,
 t,
 lag(plan,1,0) over (partition by sql_id order by snap_id, plan) pplan,
 lag(c,1,0) over (partition by sql_id order by snap_id, plan) pc,
 lag(t,1,0) over (partition by sql_id order by snap_id, plan) pt
from sql_stat
order by sql_id, snap_id, plan
) 
where
 c > 0 and pc > 0
 and plan != pplan 
 and (t/c-pt/pc)/(pt/pc)*100 > 20
order by (t/c-pt/pc)/(pt/pc)*100 desc

--select * from dba_hist_sqlstat

--select s.snap_id, s.sql_id, s.instance_number, count(*)
--from dba_hist_sqlstat s
--group by s.snap_id, s.sql_id, s.instance_number
--having count(*) > 1

--select * from dba_hist_sqlstat s where sql_id = 'br334b31xpuu3' and snap_id = 129864
