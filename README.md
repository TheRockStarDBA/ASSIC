# Automated SQL Server Installation and configuration #

ASSIC simplifies and automates the installation and configuration of SQL Server.

## Getting started ##

There are two examples of INI files included in this repo:
1. For standalone Instance *standalone.ini*
2. For clustered Instance *cluster.ini*

parameter | standalone | clustered
---------- | ---------- | ----------
ACTION | Install | InstallFailoverCluster, AddNode, RemoveNode
FAILOVERCLUSTERNETWORKNAME | Empty | \*Cluster_network_name\*


Under the hood

* Clustered parameters are used if FAILOVERCLUSTERNETWORKNAME is **Not Empty**
* For **default Instance** leave INSTANCENAME empty 
* For cluster installation please use following order:
  * On the first node in cluster ACTION=InstallFailoverCluster
  * For following cluster nodes ACTION=AddNode
  * For cluster node removal ACTION=RemoveNode

## Usage examples ##



## Invoking the program ##



## Contributing ##

Pull requests welcomed.

## Licensing ##

ASSIC is licensed under the Apache License, Version 2.0. See LICENSE for the full license text.
