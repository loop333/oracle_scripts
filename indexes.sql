select decode(col.column_position,1,col.index_name,''), col.column_name, comm.comments
from dba_ind_columns col, dba_col_comments comm
where col.table_owner = 'OWNER' and col.table_name = 'TABLE_NAME'
and comm.owner (+) = col.table_owner and comm.table_name (+) = col.table_name and comm.column_name (+) = col.column_name
order by index_name, column_position
