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

-- блокирующие и ожидающие сессии (нужно выполнять на каждой ноде)
select
 hs.sid h_sid, hs.serial# h_serial, hs.username h_user, hs.machine, hs.program, hs.sql_id, hs.prev_sql_id,
  ws.sid w_sid, ws.serial# w_serial, ws.username w_user  
from
 dba_kgllock w, dba_kgllock h, v$session ws, v$session hs
where
 h.kgllkmod not in (0,1) and h.kgllkreq in (0,1)
 and w.kgllkmod in (0,1) and w.kgllkreq not in (0,1)
 and w.kgllktype = h.kgllktype
 and w.kgllkhdl = h.kgllkhdl
 and w.kgllkuse = ws.saddr
 and h.kgllkuse = hs.saddr

begin
 for c in
  (select
   distinct 'alter system kill session '''||hs.sid||', '||hs.serial#||''' immediate' cmd, hs.username hs_username 
  from
   dba_kgllock w, dba_kgllock h, v$session ws, v$session hs
  where
   h.kgllkmod not in (0,1) and h.kgllkreq in (0,1)
   and w.kgllkmod in (0,1) and w.kgllkreq not in (0,1)
   and w.kgllktype = h.kgllktype
   and w.kgllkhdl = h.kgllkhdl
   and w.kgllkuse = ws.saddr
   and h.kgllkuse = hs.saddr) loop
    dbms_output.put_line(c.hs_username);
--    execute immediate c.cmd; 
   end loop;  
end;

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
select /*+ index(ash WRH$_ACTIVE_SESSION_HISTORY_PK) */
 ash.sample_time--, o.*
 , ash.*
from sys.wrh$_event_name e, sys.wrm$_snapshot snap, sys.wrh$_active_session_history ash--, sys.x_$kglob o
where e.event_name = 'library cache lock'
and snap.begin_interval_time >= to_date('28.01.2015 10:00','DD.MM.YYYY HH24:MI')
and snap.end_interval_time < to_date('28.01.2015 12:11','DD.MM.YYYY HH24:MI') and ash.snap_id = snap.snap_id
and ash.dbid = snap.dbid and ash.snap_id = snap.snap_id and ash.instance_number = snap.instance_number and ash.event_id = e.event_id
--and o.kglhdadr (+) = trim(to_char(ash.p1,'XXXXXXXXXXXXXXXX'))
order by ash.sample_time

select * from sys.x_$kglob o where o.kglhdadr (+) = trim(to_char('13835058120539553976','XXXXXXXXXXXXXXXX'))

-- найти текущие блокирующие объекты
select o.kglnaown, o.kglnaobj from gv$session s, sys.x_$kglob o where s.event = 'library cache lock'
and s.p1 = to_number(rawtohex(o.kglhdadr),'XXXXXXXXXXXXXXXX')
  
-- найти недавние блокирующие объекты
select ash.sample_time, o.kglnaown, o.kglnaobj, o.*
from gv$active_session_history ash, sys.x_$kglob o
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
 
--select * from dba_kgllock where kgllkreq != 0

select 
 w1.sid waiting_session, 
 h1.sid holding_session, 
 w.kgllktype lock_or_pin, 
 w.kgllkhdl address, 
 decode(h.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown' ) mode_held, 
 decode(w.kgllkreq, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown' ) mode_requested 
from
 dba_kgllock w, 
 dba_kgllock h, 
 gv$session w1, 
 gv$session h1 
where
 h.kgllkmod not in (0,1) and h.kgllkreq in (0,1) 
 and w.kgllkmod in (0,1) and w.kgllkreq not in (0,1) 
 and w.kgllktype = h.kgllktype 
 and w.kgllkhdl = h.kgllkhdl 
 and w.kgllkuse = w1.saddr 
 and h.kgllkuse = h1.saddr

create view sys.x_$kglpn as select * from sys.x$kglpn
create view sys.x_$kgllk as select * from sys.x$kgllk

select * from dba_kgllock -- library cache locks & pins
select * from sys.x_$kgllk -- library cache locks
select * from sys.x_$kglpn -- library cache pins

select * from gv$ges_blocking_enqueue
select * from gv$ges_enqueue h, gv$ges_enqueue w where w.handle = h.handle
and h.blocker > 0 and w.blocked > 0


select * from sys.x_$kgllk h, sys.x_$kgllk w where w.addr = h.addr
and h.kgllkmod > 0 and w.kgllkreq > 0

select * from dba_lock_internal h, dba_lock_internal w 
where w.lock_id1 = h.lock_id1 and w.lock_id2 = h.lock_id2
and w.mode_requested not in ('None') 

select 
 /*+ ordered */ 
 w1.sid waiting_session, 
 w1.username waiting_user, 
 h1.sid holding_session, 
 h1.serial# holding_serial, 
 h1.username holding_user, 
 w.kgllktype lock_or_pin, 
 w.kgllkhdl address, 
 decode(h.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown' ) mode_held, 
 decode(w.kgllkreq, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive', 'Unknown' ) mode_requested 
from dba_kgllock w, 
     dba_kgllock h, 
     v$session w1, 
     v$session h1 
where ( ((h.kgllkmod != 0) and (h.kgllkmod != 1) and ((h.kgllkreq = 0) or (h.kgllkreq = 1))) 
    and (((w.kgllkmod = 0) or (w.kgllkmod = 1)) and ((w.kgllkreq != 0) and (w.kgllkreq != 1))) ) 
    and w.kgllktype = h.kgllktype 
    and w.kgllkhdl = h.kgllkhdl 
    and w.kgllkuse = w1.saddr 
    and h.kgllkuse = h1.saddr
