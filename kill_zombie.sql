select 'kill -9 '||p.SPID
from gv$process p
    left join gv$session s on s.INST_ID = 2 and s.PADDR = p.ADDR
where p.inst_id = 2
and s.sid is null

select * from gv$process p where (p.inst_id,p.addr) not in (select inst_id, paddr from gv$session)


select
 *
-- 'kill -9 ' || p.spid
from gv$process p
where
 p.inst_id = 2
 and (p.inst_id, p.addr) not in (select inst_id, paddr from gv$session)
 and p.spid is not null
 and p.program not like '%(P___)'

select 'kill -9 '||p.spid, s.* from gv$session s, gv$process p where p.inst_id = s.inst_id and p.addr = s.paddr
