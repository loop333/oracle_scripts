select p1, p2, sum(time_waited) from gv$active_session_history ash where ash.sample_time > sysdate - 1/24/60 and
ash.event = 'gc buffer busy' and program like '%PRG_NAME%'
group by p1, p2
order by 3 desc

select * from gv$bh where rownum < 2

select * from dba_extents e where e.file_id = 225 and 601 between e.block_id and e.block_id + e.blocks - 1
