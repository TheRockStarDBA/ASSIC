# All

# & msiexec /quiet /i $fileExe

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Installing SQLServer 2012 Performance Dashboard"
$fileExe = "$dirSetup\Tools\SQLServer2012_PerformanceDashboard.msi"

If (Test-Path $fileExe) {
    $exitCode = (Start-Process -FilePath "msiexec.exe" -ArgumentList "/quiet /i $fileExe" -Wait -Passthru).ExitCode
} Else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Performance Dashboard binaries not found !"
    $exitCode = 11
}

if ( $exitCode -eq 0 ) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Performance Dashboard installed successfully"
} else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Performance Dashboard setup has failed: $exitCode"
}

return $exitCode
