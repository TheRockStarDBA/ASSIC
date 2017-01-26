# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServerName = $sConfig["SQLSERVERNAME"]
$sqlEdition = $sConfig["SQLEDITION"]

$logFiles = $sConfig["LOGFILES"]
."$dirSetup\scriptFunctions.ps1"

if (($sqlEdition -ne "EX") -and ($sqlEdition -ne "DS")) {

if (!$logFiles) {
  $logFiles = 60
}

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

$logs = $server.NumberOfLogFiles
if ( $logs -eq -1) { $logs = 7 }

if ($logs -eq $logFiles)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Number of Log Files set: $logs"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Number of Log Files set: $logs"
}

}
