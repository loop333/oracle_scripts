select "os_user", "owner", "object", count(*) from
(
select /*+ parallel(a 16) */
 cast(from_tz(a.ntimestamp#,'UTC') at time zone 'Asia/Yekaterinburg' as date) "date",
 a.terminal "host",
 a.userid "user",
 a.spare1 "os_user",
 aa.name "action",
 a.obj$creator "owner",
 a.obj$name "object",
 spm.name "privilege",
 a.returncode "code"
from
 sys.aud$ a, sys.audit_actions aa, system_privilege_map spm
where
 cast(from_tz(a.ntimestamp#,'UTC') at time zone 'Asia/Yekaterinburg' as date) >= to_date('28.10.2016 00:00','DD.MM.YYYY HH24:MI')
 and cast(from_tz(a.ntimestamp#,'UTC') at time zone 'Asia/Yekaterinburg' as date) < to_date('28.10.2016 14:00','DD.MM.YYYY HH24:MI')
 and aa.action (+) = a.action#
 and spm.privilege (+) = -a.priv$used
 and aa.name not in ('LOGON','LOGOFF','LOGOFF BY CLEANUP')
-- and aa.name not in ('ALTER TABLE')
-- and aa.name not in ('PL/SQL EXECUTE','EXECUTE PROCEDURE')
-- and aa.name not in ('SELECT')
-- and aa.name in ('REVOKE ROLE','SYSTEM REVOKE','REVOKE OBJECT','DROP USER','ALTER USER','GRANT OBJECT')
-- and aa.name not in ('TRUNCATE TABLE','DROP TABLE')
-- and aa.name not in ('SYSTEM GRANT','SYSTEM REVOKE','GRANT OBJECT','ALTER USER')
-- and aa.name not in ('DROP USER','ALTER USER','GRANT OBJECT','SYSTEM REVOKE',
--  'REVOKE OBJECT','SYSTEM GRANT','DROP INDEX','CREATE INDEX','TRUNCATE TABLE','ALTER TABLE','DROP TABLE','PL/SQL EXECUTE',
--  'ALTER MATERIALIZED VIEW','DROP VIEW','DISABLE TRIGGER','ENABLE TRIGGER')
order by
 a.ntimestamp#
)
group by "os_user", "owner", "object"
order by count(*) desc
