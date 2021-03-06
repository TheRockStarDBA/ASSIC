# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlSvc = $sConfig["SQLSVCACCOUNT"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Perform Volume Maintenance Privilage is being set to $sqlSvc"

$fileExe = "$dirSetup\Tools\ntrights.exe"
& $fileExe -u $sqlSvc +r SeManageVolumePrivilege

Write-Log -logfile $setupLog -level "Info" -message "Perform Volume Maintenance Privilage is currently set to $sqlSvc"
return 0
