select * from table(dbms_space.object_growth_trend('OWNER','TABLE_NAME','TABLE'))
