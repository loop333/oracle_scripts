with
param as (select to_date('09.05.2019 00:00:00','DD.MM.YYYY HH24:MI:SS') date_begin,
                 to_date('11.05.2019 00:00:00','DD.MM.YYYY HH24:MI:SS') date_end,
                 1/24/60                                                date_step
                 from dual),
scale as (select
           param.date_begin+(level-1)*param.date_step date1,
           param.date_begin+level*param.date_step date2
          from dual, param
          connect by param.date_begin+(level-1)*param.date_step between param.date_begin and param.date_end)
select
 to_char(date1, 'DD.MM.YYYY HH24:MI:SS') d,
 date1-p.date_begin v
from
 param p, scale
