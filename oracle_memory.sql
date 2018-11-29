select * from gv$process order by pga_alloc_mem desc
select * from gv$process_memory order by allocated desc

select * from gv$sga
select * from gv$sgainfo
select * from gv$sga_target_advice
select * from gv$sgastat
select * from gv$sga_resize_ops
select * from gv$pga_target_advice
select * from gv$pga_target_advice_histogram
select * from gv$pgastat

select * from gv$db_cache_advice

select sum(value) from gv$sga

