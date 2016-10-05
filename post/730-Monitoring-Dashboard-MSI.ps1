# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Installing SQLServer 2012 Performance Dashboard"

$fileExe = "$dirSetup\Tools\SQLServer2012_PerformanceDashboard.msi"
& msiexec /quiet /i $fileExe
Write-Log -logfile $setupLog -level "Info" -message "Performance Dashboard is currently installed"
