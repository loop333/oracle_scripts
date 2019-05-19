with param as
(
 select to_date('19.05.2019 06:00:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('19.05.2019 14:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time t,
 ws2.class s,
 (ws2.wait_count-ws1.wait_count) wait_count,
 (ws2.time-ws1.time) time
from
 param p, sys.wrm$_snapshot s, sys.wrh$_waitstat ws1, sys.wrh$_waitstat ws2
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and ws1.dbid = s.dbid and ws1.instance_number = s.instance_number and ws1.snap_id = s.snap_id-1
 and ws2.dbid = s.dbid and ws2.instance_number = s.instance_number and ws2.snap_id = s.snap_id
 and ws2.class = ws1.class
 and ws1.class = 'data block'
order by
 s.begin_interval_time, ws2.class

/*
bitmap block
bitmap index block
data block
extent map
file header block
free list
save undo block
save undo header
segment header
sort block
system undo block
system undo header
undo block
undo header
unused
1st level bmb
2nd level bmb
3rd level bmb
*/
