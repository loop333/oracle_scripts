select text, count(*) from 
(
select
 regexp_replace(regexp_replace(to_char(substr(sql_fulltext,1,1000)),'''.*''','@'),'[0-9]+','#') text
from
 gv$sql
)
group by text
order by count(*) desc

select text, count(*) from 
(
select
 regexp_replace(regexp_replace(to_char(substr(sql_fulltext,1,1000)),'''.*''','@'),'[0-9]+','#') text
from
 gv$sqlarea
)
group by text
order by count(*) desc


