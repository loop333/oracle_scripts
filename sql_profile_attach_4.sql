select
 extractvalue(value(d), '/hint') as outline_hints
from
 xmltable('/*/outline_data/hint'
          passing (select
                    xmltype(other_xml) as xmlval
                   from
                    gv$sql_plan
                   where
                    sql_id = '9yct47dw4ff5u'
                    and plan_hash_value = 779027034
                    and other_xml is not null
                  )
          ) d;


--select * from gv$sql where sql_id = '9yct47dw4ff5u' and plan_hash_value = 779027034
