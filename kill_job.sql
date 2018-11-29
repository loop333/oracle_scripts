/*
begin
 sys.dbms_ijob.broken(2364940, TRUE);
 sys.dbms_ijob.remove(2364940);
 commit;
end;
*/

begin
for c in
(
select
 j.job, s.inst_id, p.spid
from
 sys.job$ j, gv$lock l, gv$session s, gv$process p
where
 l.type = 'JQ' and j.job (+)= l.id2
 and s.inst_id = l.inst_id and s.sid = l.sid
 and p.inst_id = l.inst_id and p.addr = s.paddr
 and j.what like '%JOB_NAME%'
)
 loop
  dbms_output.put_line(c.inst_id || ' kill -9 ' || c.job);
  sys.dbms_ijob.broken(c.job,TRUE);
  sys.dbms_ijob.remove(c.job);
  commit;
 end loop;
end;


declare
 job       number;
 next_date date;
 inst_id   number;
 spid      number;
begin
 select job, next_date into job, next_date from dba_jobs where upper(what) like '%JOB_NAME%';
 if next_date < sysdate then
  select l.inst_id, p.spid into inst_id, spid from gv$lock l, gv$session s, gv$process p
   where l.type = 'JQ' and l.id2 = job
   and s.inst_id = l.inst_id and s.sid = l.sid
   and p.inst_id = s.inst_id and p.addr = s.paddr;
  dbms_output.put_line(inst_id || ', kill -9 ' || spid);
  sys.dbms_ijob.next_date(job,next_date+1);
  commit;
 end if;
end;
