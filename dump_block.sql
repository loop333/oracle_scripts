declare
 file_no    number;
 block_no   number;
 v_handle   utl_file.file_type;
 v_dump     varchar2(2000);
 v_filename varchar2(2000);
 v_line     varchar2(4000);
 s_id       number;
begin
 file_no := 330; -- change
 block_no := 84691; -- change

 execute immediate('alter system dump datafile ' || file_no || ' block ' || block_no);

 select value into v_dump from v$parameter where name = 'user_dump_dest';
 dbms_output.put_line(v_dump);
 execute immediate('create or replace directory user_dump_dir as ''' || v_dump || '''');
 dbms_output.put_line('create or replace directory user_dump_dir as ''' || v_dump || '''');

 s_id := userenv('sid');
 -- get exact file_name
 select lower(i.value)||'_ora_'||p.spid||'.trc' into v_filename
 from v$process p, v$session s,
 (select value from v$parameter where name = 'instance_name') i
 where p.addr = s.paddr and s.sid = s_id;

 dbms_output.put_line(v_filename);

 v_handle := utl_file.fopen('USER_DUMP_DIR', v_filename, 'R', 32767);

 loop
  begin
   utl_file.get_line(v_handle, v_line);
  exception when no_data_found then
   exit;
  end;

  dbms_output.put_line(v_line);
 end loop;
end;
