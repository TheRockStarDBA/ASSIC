-- 2008,2008R2,2012,2014

USE [master];

exec sp_configure 'show advanced options', 1;
RECONFIGURE;
exec sp_configure 'Agent XPs', 1;
exec sp_configure 'xp_cmdshell', 1
RECONFIGURE;
