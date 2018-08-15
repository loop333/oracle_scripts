select
 cast(from_tz(ntimestamp#,'UTC') at time zone 'Asia/Yekaterinburg' as date) "Date",
 userid "Login",
 spare1 "OS User", 
 userhost "Host",
 terminal "Terminal",
 regexp_substr(comment$text,'HOST=([^)]*)',1,1,'',1) "IP",
 regexp_substr(comment$text,'SOURCE_GLOBAL_NAME=([^,]*)',1,1,'',1) "DBLink Host",
 regexp_substr(comment$text,'DBLINK_NAME=([^,]*)',1,1,'',1) "DBLink",
 comment$text,
 returncode "Error"
from sys.aud$
where sessionid > (select max(sessionid)-10000 from sys.aud$)
and action# = 100
and returncode != 0
order by ntimestamp#

--select * from sys.aud$
