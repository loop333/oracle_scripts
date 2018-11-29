--select * from gv$sql

declare
 type      stat_rec is record (inst_id number, sql_id varchar2(13), child_number number, value number);
 type      stat_table is table of stat_rec;
 v_stat    stat_table;
 is_found  integer; 
 n         integer;
 v_rec     stat_rec;
begin
 dbms_output.enable(20000);
 select s.inst_id, s.sql_id, s.child_number, s.cpu_time value bulk collect into v_stat from gv$sql s;
 dbms_lock.sleep(20);
 for c in (select s.inst_id, s.sql_id, s.child_number, s.cpu_time value from gv$sql s) loop
  is_found := 0;
  for i in v_stat.first .. v_stat.last loop
   if v_stat(i).inst_id = c.inst_id and v_stat(i).sql_id = c.sql_id and v_stat(i).child_number = c.child_number then
    v_stat(i).value := c.value - v_stat(i).value;
    is_found := 1;
   end if;
  end loop;
  n := v_stat.last + 1;
  if is_found = 0 then
   v_stat.extend(1);
   v_stat(n).inst_id := c.inst_id;
   v_stat(n).sql_id := c.sql_id;
   v_stat(n).child_number := c.child_number;
   v_stat(n).value := c.value;
  end if;
 end loop;  

 for i in v_stat.first .. v_stat.last loop
  for j in i+1 .. v_stat.last loop
   if v_stat(j).value > v_stat(i).value then
    v_rec := v_stat(j);
    v_stat(j) := v_stat(i);
    v_stat(i) := v_rec;
   end if;   
  end loop;
 end loop;

 for i in 1 .. 30 loop
  if v_stat(i).value > 0 then
   begin
    dbms_output.put_line(v_stat(i).inst_id||' '||v_stat(i).sql_id||' '||v_stat(i).child_number||' '||to_char(v_stat(i).value,'999999999'));
   exception when others then
    null;
   end;  
  end if;
 end loop;
end;

