select
 p.sql_id, p.plan_hash_value plan, p.operation, p.options, p.object_type type, p.object_owner owner, p.object_name name, p.cardinality,
 u.username, s.service, s.module, s.action
from gv$sql_plan p, gv$sql s, dba_users u
where p.cardinality is not null
and s.inst_id = p.inst_id and s.sql_id = p.sql_id and s.plan_hash_value = p.plan_hash_value and s.child_number = p.child_number
and u.user_id = s.parsing_user_id
order by p.cardinality desc

--select * from gv$sql
