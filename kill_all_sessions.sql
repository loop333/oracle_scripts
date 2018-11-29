select s.inst_id, 'kill -9 ' || p.spid, s.username, s.machine
from gv$session s, gv$process p where s.inst_id=p.inst_id and s.paddr=p.addr
and s.username like 'USER_NAME'
