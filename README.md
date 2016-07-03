# Automated SQL Server Installation and configuration #

ASSIC simplifies and automates the installation and configuration of SQL Server.

## Prerequisites ##

* Power Shell 3+
* Supports SQL server 2008+

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

## Contributing ##

Pull requests welcomed.

## Licensing ##

ASSIC is licensed under the Apache License, Version 2.0. See [LICENSE] (https://github.com/deckTECHeu/ASSIC/blob/master/LICENSE) for the full license text.
