select * from gv$asm_disk
select * from gv$asm_disk_iostat
select * from gv$asm_disk_stat
select * from gv$asm_file
select * from gv$asm_diskgroup
select * from gv$asm_diskgroup_stat
select * from gv$asm_volume_stat

select * from gv$iofuncmetric
select * from gv$iofuncmetric_history
select * from gv$iostat_function
select * from gv$filestat

select max(average_read_time), max(average_write_time)
from gv$filemetric
where begin_time > sysdate - 10/24/60

select * from gv$filemetric


select * from gv$fixed_view_definition where upper(view_definition) like '%WRITE%'


