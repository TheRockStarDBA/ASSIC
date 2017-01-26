# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

$fileExe = "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard"

If (Test-Path $fileExe) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Performance Dashboard Directory exit"
} Else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Performance Dashboard Directory not found !"
}
