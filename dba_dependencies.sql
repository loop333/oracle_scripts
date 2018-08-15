-- �������, �� ������� ������� ��������� ������
select lpad(' ',3*level)||referenced_type||' '||referenced_owner||'.'||referenced_name, referenced_link_name
from dba_dependencies d
where 1=1
-- and referenced_type not in ('TABLE','SYNONYM','TYPE','VIEW','NON-EXISTENT') and referenced_owner not in ('SYS') --and level = 1
start with type = 'PACKAGE BODY' and owner = 'OWNER' and name = 'NAME'
connect by prior referenced_type = type and prior referenced_owner = owner and prior referenced_name = name

--select * from dba_dependencies d
--where type = 'PACKAGE BODY' and owner = 'CRM' and name = 'CUSTOM_CRM_VS_SM'

-- �������, ��������� �� ���������� �������
select lpad(' ',3*level)||type||' '||owner||'.'||name
from dba_dependencies d
start with referenced_type = 'PROCEDURE' and referenced_owner = 'OWNER' and referenced_name = 'NAME'
connect by prior type = referenced_type and prior owner = referenced_owner and prior name = referenced_name

-- �������, ��������� �� ���������� ������� (� ������ ����������� ��������� ������ �� ���� ������)
select lpad(' ',3*level)||type||' '||owner||'.'||name, connect_by_iscycle
from
(
select type, owner, name, referenced_type, referenced_owner, referenced_name, referenced_link_name from dba_dependencies
union all
select 'PACKAGE', owner, object_name, 'PACKAGE BODY', owner, object_name, null from dba_objects
) d
start with referenced_type = 'TABLE' and referenced_owner = 'OWNER' and referenced_name = 'NAME'
connect by nocycle
prior type = referenced_type and prior owner = referenced_owner and prior name = referenced_name

-- �������, �� ������� ������� ��������� ������ (� ������ ����������� ��������� ������ �� ���� ������)
select lpad(' ',3*level)||referenced_type||' '||referenced_owner||'.'||referenced_name, connect_by_iscycle
from
(
select type, owner, name, referenced_type, referenced_owner, referenced_name, referenced_link_name from dba_dependencies
union all
select 'PACKAGE', owner, object_name, 'PACKAGE BODY', owner, object_name, null from dba_objects
) d
where referenced_type not in ('TABLE','SYNONYM','TYPE','VIEW','NON-EXISTENT') and referenced_owner not in ('SYS') --and level = 1
start with type = 'PACKAGE BODY' and owner = 'OWNER' and name = 'NAME'
connect by nocycle
prior referenced_type = type and prior referenced_owner = owner and prior referenced_name = name
