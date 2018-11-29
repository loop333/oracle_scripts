SELECT path
FROM (
  SELECT grantee,
    sys_connect_by_path(privilege, ':')||':'||grantee path
  FROM (
    SELECT grantee, privilege, 0 role
    FROM dba_sys_privs
    UNION ALL
    SELECT grantee, granted_role, 1 role
    FROM dba_role_privs)
  CONNECT BY privilege=prior grantee
  START WITH role = 0)
WHERE grantee = 'USER_NAME'
OR grantee='PUBLIC'

SELECT LPAD(' ', 2*level) || granted_role "USER PRIVS"
FROM (
  SELECT NULL grantee, username granted_role
  FROM dba_users
  WHERE username = 'USER_NAME'
  UNION
  SELECT grantee, granted_role
  FROM dba_role_privs
  UNION
  SELECT grantee, privilege
  FROM dba_sys_privs)
START WITH grantee IS NULL
CONNECT BY grantee = prior granted_role;
