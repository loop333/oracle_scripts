--select * from dba_hist_sga
--select * from dba_hist_sgastat

with
param as (select &<name="Begin" type="date" default="sysdate-1"> date_begin,
                 &<name="End" type="date" default="sysdate"> date_end
                 from dual)
select
 snap.begin_interval_time,
 (select ss.bytes from sys.wrh$_sgastat ss
  where ss.snap_id = snap.snap_id and ss.dbid = snap.dbid and ss.instance_number = 2
  and ss.pool = 'shared pool' and ss.name = 'sql area') bis2,
 (select ss.bytes from sys.wrh$_sgastat ss
  where ss.snap_id = snap.snap_id and ss.dbid = snap.dbid and ss.instance_number = 3
  and ss.pool = 'shared pool' and ss.name = 'sql area') bis3
from param p, sys.wrm$_snapshot snap
where
 snap.dbid = (select dbid from v$database)
 and snap.instance_number = 2
 and snap.begin_interval_time <= p.date_end and snap.end_interval_time >= p.date_begin
order by snap.begin_interval_time

--select distinct pool, name from sys.wrh$_sgastat
--order by pool, name

/*
1  java pool  free memory
2  java pool  joxlod exec hp
3	large pool	free memory
4	large pool	KSFQ Buffers
5	large pool	PX msg pool
6	shared pool	ASH buffers
7	shared pool	ASM extent pointer array
8	shared pool	CCursor
9	shared pool	db_block_hash_buckets
10	shared pool	FileOpenBlock
11	shared pool	free memory
12	shared pool	gcs resources
13	shared pool	gcs shadows
14	shared pool	ges enqueues
15	shared pool	ges resource
16	shared pool	Heap0: KGL
17	shared pool	KGH: NO ACCESS
18	shared pool	kglsim object batch
19	shared pool	KQR L PO
20	shared pool	KQR X PO
21	shared pool	library cache
22	shared pool	PCursor
23	shared pool	PL/SQL DIANA
24	shared pool	sql area
25	shared pool	sql area:PLSQL
26	shared pool	state objects
27	streams pool	free memory
28	null	buffer_cache
29	null	fixed_sga
30	null	log_buffer
*/
