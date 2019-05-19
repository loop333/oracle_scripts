with param as
(
 select to_date('26.04.2019 20:30:00', 'DD.MM.YYYY HH24:MI:SS') begin,
        to_date('27.04.2019 11:00:00', 'DD.MM.YYYY HH24:MI:SS') end
        from dual
)
select
 s.begin_interval_time d,
 fn.function_name s,
 (if2.small_read_megabytes - if1.small_read_megabytes) small_read_megabytes,
 (if2.small_write_megabytes - if1.small_write_megabytes) small_write_megabytes,
 (if2.large_read_megabytes - if1.large_read_megabytes) large_read_megabytes,
 (if2.large_write_megabytes - if1.large_write_megabytes) large_write_megabytes,
 (if2.small_read_reqs - if1.small_read_reqs) small_read_reqs,
 (if2.small_write_reqs - if1.small_write_reqs) small_write_reqs,
 (if2.large_read_reqs - if1.large_read_reqs) large_read_reqs,
 (if2.large_write_reqs - if1.large_write_reqs) large_write_reqs,
 (if2.number_of_waits - if1.number_of_waits) number_of_waits,
 (if2.wait_time - if1.wait_time) wait_time
from
 param p, sys.wrm$_snapshot s, sys.wrh$_iostat_filetype_name fn, sys.wrh$_iostat_filetype if1, sys.wrh$_iostat_filetype if2
where
 s.begin_interval_time < p.end and s.end_interval_time > p.begin
 and fn.dbid = s.dbid
-- and fn.function_name = 'Buffer Cache Reads'
 and if1.dbid = s.dbid and if1.instance_number = s.instance_number and if1.snap_id = s.snap_id-1 and if1.function_id = fn.function_id
 and if2.dbid = s.dbid and if2.instance_number = s.instance_number and if2.snap_id = s.snap_id and if2.function_id = fn.function_id
 and if1.function_id = fn.function_id
 and if2.function_id = fn.function_id
order by
 s.begin_interval_time, fn.function_name
