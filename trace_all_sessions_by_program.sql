-- by PRG_NAME
begin
 for c in (select sid, serial# from gv$session where program like '%PRG_NAME%') loop
  sys.dbms_system.set_ev(c.sid,c.serial#, 10046, 0, '');
 end loop;
end;

-- by service, module
begin
 dbms_monitor.serv_mod_act_trace_enable('SERVICE_NAME', 'MODULE_NAME', null, true, true);
-- dbms_monitor.serv_mod_act_trace_disable('SERVICE_NAME', 'MODULE_NAME', null);
end;

-- by username, action
begin
 for c in (select service_name, module, action from gv$session where username = 'USER_NAME' and action like '%ACTION%') loop
  dbms_monitor.serv_mod_act_trace_enable(c.service_name, c.module, c.action, true, true);
--  dbms_monitor.serv_mod_act_trace_disable(c.service_name, c.module, c.action);
 end loop;
end;

-- by username, program_name, action
begin
 for c in (select service_name, module, action from gv$session
           where username = 'USER_NAME' and program like '%PRG_NAME%' and action like '%ACTION%') loop
  begin
   dbms_monitor.serv_mod_act_trace_enable(c.service_name, c.module, c.action, true, true);
--   dbms_monitor.serv_mod_act_trace_disable(c.service_name, c.module, c.action);
  exception when others then
   null;
  end;
 end loop;
end;

-- by username, module, action, current instance
begin
 for c in (select sid, serial# from gv$session s, v$instance i where s.inst_id = i.instance_number
           and s.username = 'USER_NAME' and s.module = 'MODULE' and s.action = 'ACTION') loop
  dbms_monitor.session_trace_enable(c.sid, c.serial#, true, true);
 end loop;
end;
