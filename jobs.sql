select l.SID, l.id2 JOB, j.FAILURES, j.what
    LAST_DATE, substr(to_char(last_date,'HH24:MI:SS'),1,8) LAST_SEC,
    THIS_DATE, substr(to_char(this_date,'HH24:MI:SS'),1,8) THIS_SEC,
    l.INST_ID instance
  from sys.job$ j, gv$lock l
  where l.type = 'JQ' and j.job (+)= l.id2

select
 l.inst_id, j.field1 instance, l.sid, l.id2 job, j.lowner, j.powner, j.cowner, decode(mod(j.flag,2),1,'Y',0,'N','?') broken, j.failures, j.what, j.last_date, j.this_date, j.next_date, j.interval#
from
 sys.job$ j, gv$lock l
where
 l.type = 'JQ' and j.job (+)= l.id2


select * from gv$lock where type = 'JQ'

select lowner, powner, cowner, last_date, this_date, next_date, interval#, what, failures from sys.job$ where what like 'begin execute%'

select j.what from dba_jobs_running r, dba_jobs j where j.job = r.job
