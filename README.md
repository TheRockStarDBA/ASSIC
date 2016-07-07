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
* External executables in subdirectory Tools
  * ntrights.exe => Set SecPol permissions
  * SQLServer2012_PerformanceDashboard.msi => Installs SQL Dashboard
  * setup.sql => configures Performance Dashboard
  * QtWeb.exe => Command line Web Browser

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

1. [x] Set up static TCP port
2. [x] Local security policy rights => Locked Pages in Memory
3. [x] Local security policy rights => Perform Volume Maintenance Tasks
4. [ ] Tempdb => Increase number of data files
5. [ ] Tempdb => Local Tempdb on cluster
6. [ ] SQL Startup Parameters => Trace Flag -T845 for Standard Edition
7. [ ] SQL Startup Parameters => Trace Flag -T1117 to grow all files in a file group equally
8. [ ] SQL Startup Parameters => Trace Flag -T1118 to disable mixed extends
9. [ ] Global Configuration Settings => Min and Max Server Memory, max degree of parallelism, fill factor
10. [ ] Model DB configuration
11. [ ] Increase Error Log files  
12. [ ] Dashboard binary Installation
13. [ ] Dashboard SQL script Execution
14. [ ] Securing sa account
15. [ ] Jobs => Modify Microsoft Default Job
16. [ ] Jobs => OLA Database Maintenance, Database Backup and Cleanup
17. [ ] Jobs => Cleanup
18. [ ] Jobs => Monitoring parsing Error log file
19. [ ] Jobs => monitoring blocking
20. [ ] Jobs => Auditing
21. [ ] Database Mail Configuration

## Contributing ##

Pull requests welcomed.

## Licensing ##

ASSIC is licensed under the Apache License, Version 2.0. See [LICENSE] (https://github.com/deckTECHeu/ASSIC/blob/master/LICENSE) for the full license text.
