# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServerName = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"


# [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

[string] $sqlAudit = $server.Settings.AuditLevel

if ( $sqlAudit -eq "Failure" ) {
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => SQL Server Auditing Level is: $sqlAudit"
  } else {
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> SQL Server Auditing Level is: $sqlAudit"
  }
