select
 b.tablespace_name,
 nvl((select sum(trunc(fs1.blocks/b.next)) from dba_free_space fs1 where fs1.tablespace_name = b.tablespace_name),0) free_extents,
 nvl((select trunc(sum(fs2.bytes)/1024/1024) from dba_free_space fs2 where fs2.tablespace_name = b.tablespace_name),0) free_megabytes,
 (select trunc(sum(df.bytes)/1024/1024) from dba_data_files df where df.tablespace_name = b.tablespace_name) total_megabytes,
 b.next next_extent
from
(
select
 t.tablespace_name,
 case
  when t.allocation_type != 'SYSTEM' then max(s.next_extent/t.block_size)
  when max(extents) < 16 then 8
  when max(extents) < 79 then 128
  when max(extents) < 199 then 1024
  else 8192
 end next
from
 dba_tablespaces t, dba_segments s 
where
 t.contents != 'TEMPORARY'
 and s.tablespace_name (+) = t.tablespace_name
 group by t.allocation_type, t.tablespace_name
) b

