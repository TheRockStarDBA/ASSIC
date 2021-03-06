# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$instanceName = $sConfig["INSTANCENAME"]
$action = $sConfig["ACTION"]

."$dirSetup\scriptFunctions.ps1"

if ($instanceName -eq "MSSQLSERVER") {
  $SQLsvc = $instanceName
  $AGTsvc = "SQLSERVERAGENT"
} else {
  $SQLsvc = "MSSQL$" + $instanceName
  $AGTsvc = "SQLAgent$" + $instanceName
}

if ($action -eq "InstallFailoverCluster" -or $action -eq "AddNode" -or $action -eq "RemoveNode") {
  Write-Log -logfile $setupLog -level "Info" -message "$AGTsvc and $SQLsvc are set to Manual"
  Set-Service $SQLsvc -startuptype "Manual"
  Set-Service $AGTsvc -startuptype "Manual"
} else {
  Write-Log -logfile $setupLog -level "Info" -message "$AGTsvc and $SQLsvc are set to Automatic"
  Set-Service $SQLsvc -startuptype "Automatic"
  Set-Service $AGTsvc -startuptype "Automatic"
}
