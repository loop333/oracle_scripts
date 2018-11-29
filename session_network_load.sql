declare
 type      stat_rec is record (inst_id number, sid number, serial# number, statistic# number, value number);
 type      stat_table is table of stat_rec;
 v_stat    stat_table;
 is_found  integer; 
 n         integer;
 stat_name varchar2(100);
 sess_name varchar2(255);
 v_rec     stat_rec;
begin
 dbms_output.enable(20000);
 select s.inst_id, s.sid, s.serial#, ss.statistic#, ss.value bulk collect into v_stat from gv$sesstat ss, gv$session s
  where ss.statistic# in (589,590,592,593,595,596,597,598) and ss.value != 0 and s.inst_id = ss.inst_id and s.sid = ss.sid;
 dbms_lock.sleep(10);
 for c in (select s.inst_id, s.sid, s.serial#, ss.statistic#, ss.value from gv$sesstat ss, gv$session s
            where ss.statistic# in (589,590,592,593,595,596,597,598) and ss.value != 0 and s.inst_id = ss.inst_id and s.sid = ss.sid) loop
  is_found := 0;
  for i in v_stat.first .. v_stat.last loop
   if v_stat(i).inst_id = c.inst_id and v_stat(i).sid = c.sid and v_stat(i).serial# = c.serial# and v_stat(i).statistic# = c.statistic# then
    v_stat(i).value := c.value - v_stat(i).value;
    is_found := 1;
   end if;
  end loop;
  n := v_stat.last + 1;
  if is_found = 0 then
   v_stat.extend(1);
   v_stat(n).inst_id := c.inst_id;
   v_stat(n).sid := c.sid;
   v_stat(n).serial# := c.serial#;
   v_stat(n).statistic# := c.statistic#;
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
--    select sn.statistic#||' '||sn.name into stat_name from gv$statname sn where sn.inst_id = v_stat(i).inst_id and sn.statistic# = v_stat(i).statistic#;
    select decode(v_stat(i).statistic#,
                  589,'DB -> CLNT',
                  590,'DB <- CLNT',
                  592,'DB -> LINK',
                  593,'DB <- LINK',
                  595,'VC -> CLNT',
                  596,'VC <- CLNT',
                  597,'VC -> LINK',
                  598,'VC <- LINK',
                  'UNKNOWN'
                  ) into stat_name from dual;
    select s.username||'/'||s.machine||'/'||s.program||'/'||s.module||'/'||s.action into sess_name
     from gv$session s where s.inst_id = v_stat(i).inst_id and s.sid = v_stat(i).sid and s.serial# = v_stat(i).serial#;
    dbms_output.put_line(v_stat(i).inst_id||' '||to_char(v_stat(i).sid,'99999')||' '||to_char(v_stat(i).serial#,'999999')||' '||
     to_char(v_stat(i).value,'999999999')||' '||stat_name||' '||sess_name);
   exception when others then
    null;
   end;  
  end if;
 end loop;
end;

--select * from gv$statname where statistic# in (589,590,592,593,595,596,597,598)
--select * from gv$sysstat

--select * from gv$statname where upper(name) like '%BYTE%' and inst_id = 2

--select * from gv$sesstat ss, gv$statname sn, gv$session s
--where sn.statistic# in (589,590,592,593,595,596,597,598)
--and ss.inst_id = sn.inst_id and ss.statistic# = sn.statistic#
--and s.inst_id = ss.inst_id and s.sid = ss.sid
--order by ss.value desc

--select * from gv$sesstat ss, gv$statname sn, gv$session s
--where sn.statistic# in (223,224)
--and ss.inst_id = sn.inst_id and ss.statistic# = sn.statistic#
--and s.inst_id = ss.inst_id and s.sid = ss.sid
--order by ss.value desc


