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

  if ( $ra -eq 1 ) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Cluster Resource $clusterAgent Restart Action: $ra"
    } else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Cluster Resource $clusterAgent Restart Action: $ra"
    }

}
