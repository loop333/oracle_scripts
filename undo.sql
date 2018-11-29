select max(used_ublk) from gv$transaction
select * from gv$transaction order by used_ublk desc
--select * from sys.x$ktuxe where rownum < 2

select * from gv$transaction t, gv$session s
where t.INST_ID = s.INST_ID and
t.SES_ADDR = s.SADDR and t.USED_UBLK > 100000

select s.username, t.used_ublk from gv$transaction t, gv$session s where s.SADDR=t.SES_ADDR and t.used_ublk > 10000
