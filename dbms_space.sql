select * from dba_segments where tablespace_name = 'TS_NAME'
select * from dba_free_space where tablespace_name = 'TS_NAME'
select * from dba_extents where tablespace_name = 'TS_NAME'


select sum(bytes)/1024 from dba_segments where tablespace_name = 'TS_NAME'
select sum(bytes)/1024 from dba_free_space where tablespace_name = 'TS_NAME'
select sum(bytes)/1024 from dba_extents where tablespace_name = 'TS_NAME'

select sum(bytes)/1024, sum(user_bytes) from dba_data_files where tablespace_name = 'TS_NAME'

select num_rows, blocks, empty_blocks from dba_tables where owner = 'OWNER' and table_name = 'TABLE'
select * from dba_tables where owner = 'OWNER' and table_name = 'TABLE'

declare
 total_blocks number;
 total_bytes number;
 unused_blocks number;
 unused_bytes number;
 last_used_extent_file_id number;
 last_used_extent_block_id number;
 last_used_block number;
begin
 sys.dbms_space.unused_space('OWNER','TABLE_NAME','TABLE',total_blocks,total_bytes,unused_blocks,unused_bytes,
                             last_used_extent_file_id,last_used_extent_block_id,last_used_block,null);
 dbms_output.put_line(total_blocks);
 dbms_output.put_line(total_bytes);
 dbms_output.put_line(unused_blocks);
 dbms_output.put_line(unused_bytes);
 dbms_output.put_line(last_used_extent_file_id);
 dbms_output.put_line(last_used_extent_block_id);
 dbms_output.put_line(last_used_block);
end;

declare
 v_space_used number;
 v_space_allocated number;
 prc number;
begin
 dbms_space.object_space_usage('OWNER','TABLE_NAME','TABLE',0.001,v_space_used,v_space_allocated,prc);
 dbms_output.put_line('SPACE USED = '||v_space_used);
 dbms_output.put_line('SPACE ALLOCATED = '||v_space_allocated);
end;

select * from dba_free_space
select * from sys.sys_dba_segs
select * from sys.seg$


--dbms_space_admin.segment_number_blocks(

declare
 free number;
begin
 dbms_space.free_blocks('OWNER','TABLE_NAME','TABLE',1,free);
 dbms_output.put_line('FREE='||free);
end;


declare
 unformatted_blocks number;
 unformatted_bytes number;
 fs1_blocks number;
 fs1_bytes number;
 fs2_blocks number;
 fs2_bytes number;
 fs3_blocks number;
 fs3_bytes number;
 fs4_blocks number;
 fs4_bytes number;
 full_blocks number;
 full_bytes number;
begin
 dbms_space.space_usage('OWNER','TABLE_NAME','TABLE',
                        unformatted_blocks,
                        unformatted_bytes,
                        fs1_blocks,
                        fs1_bytes,
                        fs2_blocks,
                        fs2_bytes,
                        fs3_blocks,
                        fs3_bytes,
                        fs4_blocks,
                        fs4_bytes,
                        full_blocks,
                        full_bytes);

 dbms_output.put_line('unformated blocks='||unformatted_blocks);
 dbms_output.put_line('unformated bytes='||unformatted_bytes);
 dbms_output.put_line('fs1 blocks='||fs1_blocks);
 dbms_output.put_line('fs2 bytes='||fs1_bytes);
 dbms_output.put_line('fs2 blocks='||fs2_blocks);
 dbms_output.put_line('fs2 bytes='||fs2_bytes);
 dbms_output.put_line('fs3 blocks='||fs3_blocks);
 dbms_output.put_line('fs3 bytes='||fs3_bytes);
 dbms_output.put_line('fs4 blocks='||fs4_blocks);
 dbms_output.put_line('fs4 bytes='||fs4_bytes);
 dbms_output.put_line('full blocks='||full_blocks);
 dbms_output.put_line('full bytes='||full_bytes);
end;
