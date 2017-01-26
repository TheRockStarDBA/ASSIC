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

  Write-Log -logfile $setupLog -level "Info" -message "Validation => CHECKING Startup Type for Service accounts: $AGTsvc and $SQLsvc"

  $SQLsvcType = (Get-Service "$SQLsvc").StartType
  $AGTsvcType = (Get-Service "$AGTsvc").StartType

if ($action -eq "InstallFailoverCluster" -or $action -eq "AddNode" -or $action -eq "RemoveNode") {
  # cluster
  if ( $SQLsvcType -eq "Manual" -and $AGTsvcType -eq "Manual" ) {
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Startup Type for Service accounts is Manual"
  } else {
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Startup Type for Service accounts is Automatic"
  }
} else {
  # Standalone
if ( $SQLsvcType -eq "Automatic" -and $AGTsvcType -eq "Automatic" ) {
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Startup Type for Service accounts is Automatic"
  } else {
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Startup Type for Service accounts is Manual"
  }
}
