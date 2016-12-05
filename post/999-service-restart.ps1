# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$action = $sConfig["ACTION"]
$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]
$instanceName = $sConfig["INSTANCENAME"]
$sqlSvc = $sConfig["SQLSVCACCOUNT"]
$agtSvc = $sConfig["AGTSVCACCOUNT"]
$clusterGroup = $sConfig["FAILOVERCLUSTERGROUP"]

."$dirSetup\scriptFunctions.ps1"

if ($instanceName -eq "MSSQLSERVER") {
  $SQLsvc = $instanceName
  $AGTsvc = "SQLSERVERAGENT"
} else {
  $SQLsvc = "MSSQL$" + $instanceName
  $AGTsvc = "SQLAgent$" + $instanceName
}

if ($action -eq "InstallFailoverCluster" -or $action -eq "AddNode" -or $action -eq "RemoveNode") {
  Write-Log -logfile $setupLog -level "Info" -message "Taking SQL Services Offline"

  $clusterSQL = "SQL Server (" +  $clusterGroup + ")"
  $clusterAgent = "SQL Server Agent (" +  $clusterGroup + ")"
  Get-ClusterResource $clusterSQL | Stop-ClusterResource
  Get-ClusterResource $clusterAgent | Start-ClusterResource

  Write-Log -logfile $setupLog -level "Info" -message "Taking SQL Services Online"

} else {
  Write-Log -logfile $setupLog -level "Info" -message "Restarting the SQL Services: $SQLsvc, $AGTsvc"

  get-service | ?{$_.Name -eq $SQLsvc} | restart-service -force
  get-service | ?{$_.Name -eq $AGTsvc} | restart-service -force

  Write-Log -logfile $setupLog -level "Info" -message "SQL Services: have been recycled: $SQLsvc, $AGTsvc"
}
