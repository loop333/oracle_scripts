@echo off
set path=c:\oracle\product\10.2.0\client_1\bin
set NLS_LANG=RUSSIAN_CIS.RU8PC866

sqlplus.exe user/pass@db @export_package.sql OWNER PACKAGE_NAME
