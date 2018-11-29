declare
 cnt       number;
 ret       integer;
 size_mb   number;
 num_ref   number;
 num_child number;
 comments  varchar2(4000);
 scn       number;
begin
 scn := TYPE_OLD_SCN_HERE;
 dbms_output.enable(80000);
 dbms_output.put_line('OWNER;TABLE_NAME;SIZE_MB;NUM_REF_OBJ;NUM_CHILD_TABLE;COMMENTS');
 for c in (select
            t.owner,
            t.table_name
           from
            dba_tables t,
            dba_external_tables et
           where
            et.owner (+) = t.owner and et.table_name (+) = t.table_name
            and et.table_name is null
            and nvl(t.iot_type,'-') != 'IOT_OVERFLOW'
            and t.table_name not in ('_default_auditing_options_','DUAL','LINK$','USER_HISTORY$')
           order by t.owner, t.table_name
           owner not in ('SYSTEM')
          )
 loop
  dbms_pipe.pack_message(c.owner||'.'||c.table_name);
  ret := dbms_pipe.send_message('TEST',30);
  begin
   execute immediate 'select /*+ parallel(t 8) */ count(1) from '||c.owner||'.'||c.table_name||' t where ora_rowscn > '||scn||' and rownum < 2' into cnt;
   if cnt < 1 then
    execute immediate 'select count(1) from '||c.owner||'.'||c.table_name||' where rownum < 2' into cnt;
    if cnt > 0 then
     select round(sum(bytes)/1024/1024) into size_mb from dba_segments where owner = c.owner and segment_name = c.table_name;
     select count(*) into num_ref from dba_dependencies where referenced_type = 'TABLE' and referenced_owner = c.owner and referenced_name = c.table_name;
     select count(*) into num_child from dba_constraints parent, dba_constraints child where parent.owner = c.owner and parent.table_name = c.table_name
      and child.constraint_type = 'R' and child.r_owner = parent.owner and child.r_constraint_name = parent.constraint_name;
     select regexp_replace(comments,'\s+',' ') into comments from dba_tab_comments where table_type = 'TABLE' and owner = c.owner and table_name = c.table_name;
     dbms_output.put_line(c.owner||';'||c.table_name||';'||size_mb||';'||num_ref||';'||num_child||';'||comments);
    end if;
   end if;
  exception
   when others then
    if -sqlcode = 20000 then
     raise_application_error(sqlcode,sqlerrm);
    end if;
    if -sqlcode = 942 then
     dbms_pipe.pack_message('Table doesnt exists');
     ret := dbms_pipe.send_message('TEST',30);
    end if;
  end;
 end loop;
end;

-----------------------------------------------------------------------------------------------------------------------------
--select timestamp_to_scn(to_date('20.06.2012','DD.MM.YYYY')) from dual
--select timestamp_to_scn(to_timestamp('01.06.2012 00:00:00','DD.MM.YYYY HH24:MI:SS')) as scn from dual
--select * from sys.smon_scn_time
--select ora_rowscn, ctime, mtime, stime from sys.obj$ order by ora_rowscn
--select * from gv$archived_log
