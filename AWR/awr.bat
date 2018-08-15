@echo off
set path=c:\oracle\product\11.2.0\client_1\bin
set NLS_LANG=RUSSIAN_CIS.RU8PC866
sqlplus.exe /NOLOG @awr.sql
rem sqlplus.exe /NOLOG @awr_crm.sql
