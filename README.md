# Automated SQL Server Installation and configuration #

ASSIC simplifies and automates the installation and configuration of SQL Server.

Script executes first scripts located in **Pre** directory, performs installation and then finally executes scripts located in **Post** directory.
All scripts with extensions .sql and .ps1 will be executed. To skip particular script add '\_' before its name.
In first line of the scripts we can decide for which SQL Versions it will be executed.

* for sql scripts => \# 2008,2008R2,2012,2014
* for ps1 scripts => -- 2008,2008R2,2012,2014

## Prerequisites ##

* Power Shell 3+
* Supports .sql and .ps1 scripts in Pre and Post directories
* Supports SQL server 2008+
* External executables in subdirectory **Tools**
  * ntrights.exe => Set SecPol permissions
  * SQLServer2012_PerformanceDashboard.msi => Installs SQL Dashboard
  * setup.sql => configures Performance Dashboard
  * QtWeb.exe => Command line Web Browser
  * MaintenanceSolution.sql => creates stored procedures for OLA. This script has to be modified as follows:
  Line 32: SET @CreateJobs 		 = $(CreateJobs)
  or
  SET @CreateJobs 		 = 'N'

## Getting started ##

There are two examples of INI files included in this repo:

1. For standalone Instance *standalone.ini*
2. For clustered Instance *cluster.ini*

parameter | standalone | clustered
---------- | ---------- | ----------
ACTION | Install | InstallFailoverCluster, AddNode, RemoveNode
FAILOVERCLUSTERNETWORKNAME | Empty | \<Cluster_network_name>

### Under the hood ###

* Clustered parameters are used if FAILOVERCLUSTERNETWORKNAME is **Not Empty**
* For **default Instance** leave INSTANCENAME empty
* For cluster installation please use following order:
  * On the first node in cluster ACTION=InstallFailoverCluster
  * For following cluster nodes ACTION=AddNode
  * For cluster node removal ACTION=RemoveNode

### Cluster Support ###

Following scripts have to be run on all cluster nodes:
* Config-setSqlPort.ps1
* LocSec-setLockMemory.ps1
* Add-WindowsAdmins.ps1
* Monitoring-Dashboard-MSI.ps1

### Opened Issues ###

* SQL scripts via PS or natively
* Return value from SQL scripts

### Parameters ###

1. Mandatory

  * Parameter 1 => pIniFile to specify template file
  * Parameter 2 => pSAPWD to set password for sa user, same password will be used for all service accounts if they will be not specified

2. Optional

  * Parameter 3 => pSQLSVCPASSWORD to set password for SQLSVC account, same password will be used for other Service accounts
  * Parameter 4 => pAGTSVCPASSWORD to set password for AGTSVC account, same password will be used for Analysis Services Service
  * Parameter 5 => pASSVCPASSWORD to set password for ASSVC account.

3. Switches

  * Switch 1 => SkipPre to skip pre-install steps
  * Switch 2 => SkipInstall to skip install steps
  * Switch 3 => SkipPost to skip post-install steps
  * Switch 4 => ShowCmd to create installation CMD based on INI file

### Usage examples ###

  * Example1 => ./setup-sql.ps1 \<Template File> \<SA Passowrd> \<switches>
  * Example2 => ./setup-sql.ps1 'SQLServer.ini' 'secret' -skipPost -skipPre
  * Example3 => ./setup-sql.ps1 'SQLServer.ini' 'secret' -skipInstall -skipPre

## Task List

### Pre Installation Scripts

1. [ ] Creating Service accounts in Active directory
2. [ ] Chimney Offload State

### Post Installation Scripts

  * [x] Set up static TCP port
  * [x] Local security policy rights => Locked Pages in Memory
  * [x] Local security policy rights => Perform Volume Maintenance Tasks
  * [x] Tempdb => Increase number of data files
  * [ ] Tempdb => Local Tempdb on cluster
  * [x] Change Authentication to mixed
  * [x] Set SQLSVS and SQLAGT startup type depending on Installation ACTION. (Auto - Standalone, Manual - cluster)
  * [x] SQL Startup Parameters => Trace Flag -T845 for Standard Edition
  * [x] SQL Startup Parameters => Trace Flag -T1117 to grow all files in a file group equally
  * [x] SQL Startup Parameters => Trace Flag -T1118 to disable mixed extends
  * [x] Add local Windows Administrators
  * [x] Global Configuration Settings => Min and Max Server Memory, max degree of parallelism, fill factor
  * [x] Global Configuration Settings Others
  * [x] Model DB configuration
  * [x] Increase Error Log files  
  * [x] Performance Dashboard binary Installation
  * [x] Creating supporting OLA stored procedures
  * [ ] Creating other stored procedures
  * [ ] Securing sa account
  * [x] Jobs => Create job categories
  * [x] Jobs => Modify Microsoft Default Job
  * [ ] Jobs => OLA Database Maintenance, Database Backup and Cleanup
  * [ ] Jobs => Cleanup
  * [ ] Jobs => Monitoring parsing Error log file
  * [ ] Jobs => monitoring blocking
  * [ ] Jobs => Auditing
  * [ ] Database Mail Configuration

## Contributing ##

Pull requests welcomed.

## Licensing ##

ASSIC is licensed under the Apache License, Version 2.0. See [LICENSE] (https://github.com/deckTECHeu/ASSIC/blob/master/LICENSE) for the full license text.
