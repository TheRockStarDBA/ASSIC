# All

# & $fileExe -u $sqlSvc +r SeLockMemoryPrivilege

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlSvc = $sConfig["SQLSVCACCOUNT"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "The Lock Memory Privilage is being set to $sqlSvc"

$fileExe = "$dirSetup\Tools\ntrights.exe"

If (Test-Path $fileExe) {
    $exitCode = (Start-Process -FilePath $fileExe -ArgumentList "-u $sqlSvc +r SeLockMemoryPrivilege" -Wait -Passthru).ExitCode
} Else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> ntrights utility not found !"
    $exitCode = 11
}

if ( $exitCode -eq 0 ) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => The Lock Memory Privilage is set to $sqlSvc"
} else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> The Lock Memory Privilage has failed: $exitCode"
}

return $exit
