-- блокировки и их сессии
select
 count(*)
from
 dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
where
 h.kgllkmod not in (0,1) and h.kgllkreq in (0,1)
 and w.kgllkmod in (0,1) and w.kgllkreq not in (0,1)
 and w.kgllktype = h.kgllktype
 and w.kgllkhdl = h.kgllkhdl
 and w.kgllkuse = w1.saddr
 and h.kgllkuse = h1.saddr

-- блокирующие и ожидающие сессии
select
 hs.sid h_sid, hs.serial# h_serial, hs.username h_user, ws.sid w_sid, ws.serial# w_serial, ws.username w_user  
from
 dba_kgllock w, dba_kgllock h, v$session ws, v$session hs
where
 h.kgllkmod not in (0,1) and h.kgllkreq in (0,1)
 and w.kgllkmod in (0,1) and w.kgllkreq not in (0,1)
 and w.kgllktype = h.kgllktype
 and w.kgllkhdl = h.kgllkhdl
 and w.kgllkuse = ws.saddr
 and h.kgllkuse = hs.saddr

-- найти блокирующий объект в настоящее время
select * from dba_kgllock l, sys.x_$kglob o where l.kgllkreq > 0 and l.kgllkhdl = o.kglhdadr

select * from dba_kgllock l, sys.x_$kglob o
where l.kgllkhdl = o.kglhdadr
and rownum < 10

select s.inst_id from dba_kgllock l, gv$session s where l.kgllkuse = s.saddr

select * from dba_objects where last_ddl_time > sysdate - 1

select * from dba_kgllock where kgllkhdl = 'C000000C3E373950'

-- параметр мониторинга - блокировки Library Cache
select
 count(*)
from
 dba_kgllock w, dba_kgllock h
where 
 w.kgllkhdl = h.kgllkhdl
 and w.kgllktype = h.kgllktype
 and w.kgllkreq > 0
 and h.kgllkmod > 0 

-- примеры конвертации NUMBER <-> RAW
select
 p1text,
 p1,
 p1raw,
-- utl_raw.cast_from_number(p1),
-- utl_raw.cast_to_raw(p1),
-- utl_raw.cast_to_number(p1raw),
-- to_number(p1raw),
 to_char(p1),
 '<'||to_char(p1,'XXXXXXXXXXXXXXXX')||'>',
 to_number(rawtohex(p1raw),'XXXXXXXXXXXXXXXX'),
 event
from gv$session
where p1text like '%handle%'
--and ' '||rawtohex(p1raw) = to_char(p1,'XXXXXXXXXXXXXXXX')
and to_number(rawtohex(p1raw),'XXXXXXXXXXXXXXXX') = p1

-- найти блокирующий объект в прошлом по ASH
select * from sys.x_$kglob where to_number(rawtohex(kglhdadr),'XXXXXXXXXXXXXXXX') in
(
select p1 from dba_hist_active_sess_history ash where ash.snap_id = 21762
and event = 'library cache lock'
)

select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
 *
from sys.wrh$_active_session_history ash where ash.dbid = 304481731 and ash.snap_id = 21158

-- найти текущие блокирующие объекты
select o.kglnaown, o.kglnaobj from gv$session s, sys.x_$kglob o where s.event = 'library cache lock'
and s.p1 = to_number(rawtohex(o.kglhdadr),'XXXXXXXXXXXXXXXX')
  
-- найти недавние блокирующие объекты
select ash.sample_time, o.kglnaown, o.kglnaobj from gv$active_session_history ash, sys.x_$kglob o
where ash.event = 'library cache lock'
and ash.p1 = to_number(rawtohex(o.kglhdadr),'XXXXXXXXXXXXXXXX')
order by ash.sample_time


select * from sys.x_$kglob where to_number(rawtohex(kglhdadr),'XXXXXXXXXXXXXXXX') = &P1

select /*+ ordered */
 w1.sid waiting_session,
 h1.sid holding_session,
 w.kgllktype lock_or_pin,
 w.kgllkhdl address,
 decode(h.kgllkmod,0,'None',1,'Null',2,'Share',3,'Exclusive','Unknown') mode_held,
 decode(w.kgllkreq,0,'None',1,'Null',2,'Share',3,'Exclusive','Unknown') mode_requested
from
 dba_kgllock w, dba_kgllock h, v$session w1, v$session h1
where
 h.kgllkmod != 0 and h.kgllkmod != 1 and (h.kgllkreq = 0 or h.kgllkreq = 1)
 and (w.kgllkmod = 0 or w.kgllkmod = 1) and w.kgllkreq != 0 and w.kgllkreq != 1
 and w.kgllktype = h.kgllktype
 and w.kgllkhdl = h.kgllkhdl
 and w.kgllkuse = w1.saddr
 and h.kgllkuse = h1.saddr
 
select * from dba_kgllock where kgllkreq != 0

