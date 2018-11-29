declare
 v_sql_id_1          varchar2(20);
 v_sql_id_2          varchar2(20);
 v_plan_hash_value_1 number;
 v_profile_hints     sys.sqlprof_attr;
 v_sql_text          clob;
begin
 v_sql_id_1          := '10rqnv65xq4wk'; -- from_sql_id
 v_plan_hash_value_1 := 725082745; -- from_plan_hash_id
 v_sql_id_2          := '5k6r8176cq7mu'; -- to_plan_id

 select
  extractvalue(value(d), '/hint') as outline_hints
 bulk collect
 into
  v_profile_hints
 from
  xmltable('/*/outline_data/hint'
   passing (
    select
     xmltype(other_xml) as xmlval
    from
     gv$sql_plan
    where
     sql_id = v_sql_id_1
     and plan_hash_value = v_plan_hash_value_1
     and other_xml is not null
           )
          ) d;

 select
  sql_text
 into
  v_sql_text
 from
--  dba_hist_sqltext
  gv$sql
 where
  sql_id = v_sql_id_2
  and rownum = 1;

 dbms_sqltune.import_sql_profile(sql_text => v_sql_text,
                                 profile => v_profile_hints,
                                 category => 'DEFAULT',
                                 name => 'PROFILE_' || v_sql_id_2 || '_attach',
-- use force_match => true to use CURSOR_SHARING=SIMILAR behaviour, i.e. match even with differing literals
                                 force_match => false);
end;

-- select sql_text, sql_fulltext, sql_id, plan_hash_value from gv$sql where sql_fulltext like 'select%'
--select * from dba_sql_profiles where name like '%fqbm0vjvwvhhf%'
--begin
-- dbms_sqltune.drop_sql_profile('PROFILE_fqbm0vjvwvhhf_attach');
--end;
