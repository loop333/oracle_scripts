declare
 v_sql_id_1          varchar2(20);
 v_sql_id_2          varchar2(20);
 v_plan_hash_value_1 number;
 v_profile_hints     sys.sqlprof_attr;
 v_sql_text          clob;
 v_text_id           varchar2(50);
begin
 v_text_id           := 'UNIQUE_COMMENT_TEXT'; -- unique text in comment of source select
 v_sql_id_2          := 'cy0c8han443nx'; -- dest_sql_id

-- find source select
 select sql_id, plan_hash_value into v_sql_id_1, v_plan_hash_value_1
 from gv$sql where sql_fulltext like '%'||v_text_id||'%' and lower(sql_fulltext) not like 'explain plan%' and lower(sql_fulltext) not like '%gv$sql%';

-- find source select hints
 select extractvalue(value(d), '/hint') as outline_hints
 bulk collect into v_profile_hints
 from xmltable('/*/outline_data/hint'
   passing (
    select
     xmltype(other_xml) as xmlval
    from
     gv$sql_plan
    where
     sql_id = v_sql_id_1
     and plan_hash_value = v_plan_hash_value_1
     and other_xml is not null)) d;

 for i in 1 .. v_profile_hints.count loop
  dbms_output.put_line(v_profile_hints(i));
 end loop;

-- find dest select
 select
  sql_fulltext
 into
  v_sql_text
 from
--  dba_hist_sqltext
  gv$sql
 where
  sql_id = v_sql_id_2
  and rownum = 1;

-- pin profile
 dbms_sqltune.import_sql_profile(sql_text => v_sql_text,
                                 profile => v_profile_hints,
                                 category => 'DEFAULT',
                                 name => 'PROFILE_' || v_sql_id_2 || '_attach',
-- use force_match => true to use CURSOR_SHARING=SIMILAR behaviour, i.e. match even with differing literals
                                 force_match => false);
end;

--select * from gv$sql where sql_id =
--select sql_text, sql_fulltext, sql_id, plan_hash_value from gv$sql where sql_fulltext like '%'
--select * from gv$sql_plan where sql_id = '10rqnv65xq4wk'
--select * from dba_hist_sql_plan where sql_id = '10rqnv65xq4wk'
--select * from dba_hist_sqltext where sql_id = 'ar2t4a0tv16fz'
--select * from dba_sql_profiles
/*
begin
dbms_sqltune.drop_sql_profile('PROFILE_cy0c8han443nx_attach');
end;
*/
