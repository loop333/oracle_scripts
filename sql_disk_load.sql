declare
 type      stat_rec is record (sql_id varchar2(13), read_bytes number, write_bytes number);
 type      stat_table is table of stat_rec;
 v_stat    stat_table;
 is_found  integer; 
 n         integer;
-- stat_name varchar2(100);
-- sess_name varchar2(255);
 v_rec     stat_rec;
begin
 dbms_output.enable(20000);
 select sql.sql_id, sum(sql.physical_read_bytes) read_bytes, sum(sql.physical_write_bytes) write_bytes
  bulk collect into v_stat from gv$sql sql where sql.physical_read_bytes+sql.physical_write_bytes != 0 group by sql.sql_id;
 dbms_lock.sleep(10);
 for c in (select sql.sql_id, sum(sql.physical_read_bytes) read_bytes, sum(sql.physical_write_bytes) write_bytes
           from gv$sql sql where sql.physical_read_bytes+sql.physical_write_bytes != 0 group by sql.sql_id) loop
  is_found := 0;
  for i in v_stat.first .. v_stat.last loop
   if v_stat(i).sql_id = c.sql_id then
    v_stat(i).read_bytes := c.read_bytes - v_stat(i).read_bytes;
    v_stat(i).write_bytes := c.write_bytes - v_stat(i).write_bytes;
    is_found := 1;
   end if;
  end loop;
  n := v_stat.last + 1;
  if is_found = 0 then
   v_stat.extend(1);
   v_stat(n).sql_id := c.sql_id;
   v_stat(n).read_bytes := c.read_bytes;
   v_stat(n).write_bytes := c.write_bytes;
  end if;
 end loop;  

 for i in v_stat.first .. v_stat.last loop
  for j in i+1 .. v_stat.last loop
   if v_stat(j).read_bytes+v_stat(j).write_bytes > v_stat(i).read_bytes+v_stat(i).write_bytes then
    v_rec := v_stat(j);
    v_stat(j) := v_stat(i);
    v_stat(i) := v_rec;
   end if;   
  end loop;
 end loop;

 for i in 1 .. 30 loop
  if v_stat(i).read_bytes+v_stat(i).write_bytes > 0 then
   begin
    dbms_output.put_line(v_stat(i).sql_id||' '||v_stat(i).read_bytes||' '||v_stat(i).write_bytes);
   exception when others then
    null;
   end;  
  end if;
 end loop;
end;
