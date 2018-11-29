with sql_stat as
(
select
 sql_id, plan_hash_value,
 round(sum(elapsed_time_delta)/sum(executions_delta)) t
from sys.wrh$_sqlstat
group by sql_id, plan_hash_value
having sum(executions_delta) > 0
)
select
 ss.parsing_schema_name owner, ss.module, ss.action, ss.sql_profile,
 ss.sql_id,
 ss.plan_hash_value cur_plan, a.plan_hash_value opt_plan,
 round(ss.elapsed_time_delta/ss.executions_delta) cur_t, a.t opt_t,
 round((round(ss.elapsed_time_delta/ss.executions_delta)-a.t)/a.t,2) grow
from sys.wrh$_sqlstat ss,
(
select sql_id, plan_hash_value, t
from sql_stat ss1
where ss1.t = (select min(ss2.t) from sql_stat ss2 where ss2.sql_id = ss1.sql_id)
) a
where ss.snap_id = (select max(s.snap_id) from sys.wrm$_snapshot s)
and ss.executions_delta > 0
and a.sql_id = ss.sql_id and a.plan_hash_value != ss.plan_hash_value
order by (round(ss.elapsed_time_delta/ss.executions_delta)-a.t)*100/a.t desc

--select * from sys.wrh$_sqlstat where snap_id = 132064
--select max(snap_id) from sys.wrm$_snapshot
--select max(snap_id) from sys.wrh$_sqlstat
--select * from sys.wrm$_snapshot where snap_id = (select max(snap_id) from sys.wrm$_snapshot)

-- запросы, которые выполнялись, но не доработали до конца
select sql_id, count(*) from sys.wrh$_sqlstat
where executions_delta = 0 and elapsed_time_delta != 0
group by sql_id
order by count(*) desc

-- самые долгие запросы
select sql_id, sum(executions_delta), sum(elapsed_time_delta), sum(elapsed_time_delta)/decode(sum(executions_delta),0,1,sum(executions_delta))
from sys.wrh$_sqlstat
group by sql_id
order by sum(elapsed_time_delta)/decode(sum(executions_delta),0,1,sum(executions_delta)) desc
