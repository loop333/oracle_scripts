select distinct s.USERNAME, o.VALUE from gv$ses_optimizer_env o, gv$session s
where o.INST_ID = s.INST_ID and o.SID = s.SID and o.NAME = 'optimizer_features_enable'
order by o.VALUE, s.username

ALTER SESSION SET OPTIMIZER_FEATURES_ENABLE = '10.2.0.3'
