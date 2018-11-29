select distinct operation from dba_hist_sql_plan
select distinct options from dba_hist_sql_plan where upper(options) like '%FULL%'
select * from dba_hist_sql_plan

select * from dba_hist_sql_plan where options in ('FULL SCAN (MIN/MAX)','FULL SCAN DESCENDING','FULL','FAST FULL SCAN','SAMPLE FAST FULL SCAN','FULL SCAN')

select s.sql_text, stat.disk_reads from gv$sqlstats stat, gv$sql s where stat.sql_id = s.sql_id order by 2 desc
select * from gv$sql where sql_id = 'd15cdr0zt3vtp'
select * from gv$sql where sql_id = '2afx3dhpxxtjj'

select
 to_char(sn.end_interval_time,'mm/dd/rr hh24') time,
 p.owner,
 p.name,
 t.num_rows,
--   ltrim(t.cache) ch,
 decode(t.buffer_pool,'KEEP','Y','DEFAULT','N') K,
 s.blocks blocks,
 sum(a.executions_delta) nbr_FTS
from
 dba_tables t,
 dba_segments s,
 dba_hist_sqlstat a,
 dba_hist_snapshot sn,
 (select distinct
   pl.sql_id,
   object_owner owner,
   object_name name
  from
   dba_hist_sql_plan pl
  where
   operation = 'TABLE ACCESS' and options = 'FULL') p
where
 a.snap_id = sn.snap_id
 and a.sql_id = p.sql_id
 and t.owner = s.owner
 and t.table_name = s.segment_name
 and t.table_name = p.name
 and t.owner = p.owner
 and t.owner not in ('SYS','SYSTEM')
having
 sum(a.executions_delta) > 1
group by
 to_char(sn.end_interval_time,'mm/dd/rr hh24'), p.owner, p.name, t.num_rows, t.cache, t.buffer_pool, s.blocks
order by
 1 asc;

select sp.object_owner, sp.object_name,
(select sql_text from gv$sqlarea sa where sa.address = sp.address and sa.hash_value =sp.hash_value) sqltext,
(select executions from gv$sqlarea sa where sa.address = sp.address and sa.hash_value =sp.hash_value) no_of_full_scans,
(select lpad(nvl(trim(to_char(num_rows)),' '),15,' ')||' | '||lpad(nvl(trim(to_char(blocks)),' '),15,' ')||' | '||buffer_pool
 from dba_tables where table_name = sp.object_name and owner = sp.object_owner) "rows|blocks|pool"
from gv$sql_plan sp
where operation = 'TABLE ACCESS'
and options = 'FULL'
--and object_owner IN ()
order by 1,2;
