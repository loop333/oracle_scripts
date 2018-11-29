select tablespace_name, sum(bytes)/1024/1024
from dba_data_files
group by tablespace_name
order by 2 desc

select
 to_char(s.begin_interval_time,'DD.MM.YYYY HH24:MI:SS') time,
 u.tablespace_size "size",
 u.tablespace_usedsize used,
 u.tablespace_size-u.tablespace_usedsize free
from
 dba_hist_tablespace_stat t,
 dba_hist_tbspc_space_usage u,
 dba_hist_snapshot s
where
 s.begin_interval_time > sysdate - 60
 and t.snap_id = s.snap_id
 and u.snap_id = s.snap_id
 and t.tsname = 'BIS'
 and u.tablespace_id = t.ts#
 and s.instance_number = 2
order by s.begin_interval_time

select * from dba_hist_tbspc_space_usage
select * from dba_hist_tablespace_stat
select * from dba_tablespaces
select * from dba_segments
