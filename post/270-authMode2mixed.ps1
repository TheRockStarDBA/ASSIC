# 2008,2008R2,2012,2014

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

Write-Log -logfile $setupLog -level "Info" -message "Previous SQL Server Authentication Mode was $sqlMode"

$server.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Mixed
$server.Alter()
$sqlMode = $server.Settings.LoginMode

Write-Log -logfile $setupLog -level "Info" -message "Current SQL Server Authentication Mode is set to $sqlMode"
