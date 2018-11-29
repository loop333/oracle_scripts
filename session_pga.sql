select s.inst_id, s.sid, s.serial#, s.username, s.module, ss.value, sn.name
from gv$session s, gv$sesstat ss, gv$statname sn
where ss.inst_id = sn.inst_id and ss.statistic# = sn.statistic#
and s.inst_id = ss.inst_id and s.sid = ss.sid
--and sn.statistic# = 20 -- session uga memory
--and sn.statistic# = 21 -- session uga memory max
--and sn.statistic# = 25 -- session pga memory
and sn.statistic# = 26 -- session pga memory max
order by ss.value desc

--select * from gv$session where sid = 2501

select s.username, ss.value, sn.name from gv$session s, gv$sesstat ss, gv$statname sn where ss.statistic# = sn.statistic#
and s.inst_id = ss.inst_id and s.sid = ss.sid
and sn.statistic# = 26 -- 20, 21, 25, 26
order by ss.value desc

select * from gv$statname where name like '%memory%'

select * from dba_hist_osstat where snap_id = 14536

select 

-- зависает
select s.sid, s.username, s1.value, s2.value, s3.value, s4.value
from gv$session s, gv$sesstat s1, gv$sesstat s2, gv$sesstat s3, gv$sesstat s4
where s1.inst_id = s.inst_id and s1.sid = s.sid and s1.statistic# = 20
and s2.inst_id = s.inst_id and s2.sid = s.sid and s2.statistic# = 21
and s3.inst_id = s.inst_id and s3.sid = s.sid and s3.statistic# = 25
and s4.inst_id = s.inst_id and s4.sid = s.sid and s4.statistic# = 26

select * from gv$pgastat
select * from gv$sysstat where name like '%memory%'
select * from gv$sysstat where statistic# in (20,21,25,26)



