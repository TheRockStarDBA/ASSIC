# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$clusterGroup = $sConfig["FAILOVERCLUSTERGROUP"]
$action = $sConfig["ACTION"]

."$dirSetup\scriptFunctions.ps1"

if ($action -eq "InstallFailoverCluster" -or $action -eq "AddNode" -or $action -eq "RemoveNode") {

  $clusterAgent = "SQL Server Agent (" +  $clusterGroup + ")"
  $cr = Get-ClusterResource $clusterAgent
  $ra = $cr.RestartAction

  Write-Log -logfile $setupLog -level "Info" -message "Previous $clusterAgent RestartAction was $ra"

  $ra = 1

  Write-Log -logfile $setupLog -level "Info" -message "Current $clusterAgent RestartAction is set to $ra"

} else {

Write-Log -logfile $setupLog -level "Info" -message "Standalone Setup, Step not needed"

}
