begin
 for c in (select job from dba_jobs where what like '%JOB_NAME%') loop
  sys.dbms_ijob.broken(c.job, true);
  sys.dbms_ijob.instance(c.job, NEW_INST, true);
  sys.dbms_ijob.broken(c.job, false, sysdate+5/24/60/60);
  commit;
 end loop;
end;

--select * from dba_jobs where what like '%JOB_NAME%'
