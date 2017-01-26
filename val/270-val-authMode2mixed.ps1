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

[string] $sqlMode = $server.Settings.LoginMode

if ( $sqlMode -eq "Mixed" ) {
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => SQL Server Authentication Mode is: $sqlMode"
  } else {
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> SQL Server Authentication Mode is: $sqlMode"
  }
