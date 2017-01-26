-- All

USE msdb;
GO
EXEC dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Microsoft Default' ;
EXEC dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'OLA Database Maintenance';
EXEC dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'OLA Database Backup';
EXEC dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'OLA Cleanup';
EXEC dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'SQL Cleanup' ;
GO
