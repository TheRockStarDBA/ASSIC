# 2008,2008R2,2012,2014

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

Write-Log -logfile $setupLog -level "Info" -message "Number of Log Files is being set to $logFiles"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

$server.NumberOfLogFiles = $logFiles
$server.Alter()
$server.Refresh()

Write-Log -logfile $setupLog -level "Info" -message "Number of Log Files is currently set to $logFiles"

} else {
  Write-Log -logfile $setupLog -level "Info" -message "Number of Log Files not supported"
}
