select dbms_xplan.display_cursor(sql_id,sql_child_number,'ADVANCED') from
(
(select distinct sql_id, sql_child_number from gv$session where username = 'USER_NAME' and sql_id is not null)
)

select * from gv$sql_plan sp,
(
(select distinct sql_id, sql_child_number from gv$session where username = 'USER_NAME' and sql_id is not null)
) a
where sp.sql_id = a.sql_id and sp.child_number = a.sql_child_number
