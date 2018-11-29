--select s.address, s.hash_value, s.* from gv$sql s where sql_id = 'frnutuwjfxtjc' and inst_id = 1

declare 
 v_address    varchar2(20);
 v_hash_value number;
begin
 v_address := null;
 select s.address, s.hash_value into v_address, v_hash_value from gv$sql s where sql_id = 'frnutuwjfxtjc' and inst_id = 1;
 
 if v_address is not null then
  execute immediate 'alter session set events ''5614566 trace name context forever''';
  sys.dbms_shared_pool.purge(v_address||','||to_char(v_hash_value),'C',1);
 end if;
end;

