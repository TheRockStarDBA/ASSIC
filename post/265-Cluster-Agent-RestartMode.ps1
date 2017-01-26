# All

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
  Write-Log -logfile $setupLog -level "Info" -message "Previous $clusterAgent RestartAction was $($cr.RestartAction)"
  $cr.RestartAction = 1
  Write-Log -logfile $setupLog -level "Info" -message "Current $clusterAgent RestartAction is set to $($cr.RestartAction)"
} else {
Write-Log -logfile $setupLog -level "Info" -message "Standalone Setup, Step not needed"
}
