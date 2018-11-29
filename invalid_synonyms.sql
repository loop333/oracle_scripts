--select * from dba_synonyms where owner != 'PUBLIC' and table_owner = 'SYS'

select * from dba_synonyms s, dba_objects o
where s.table_owner is not null and s.db_link is null
and o.owner (+) = s.table_owner
and o.object_name (+) = s.table_name
and o.owner is null
order by s.owner, s.synonym_name
