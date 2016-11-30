# 2008

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlEdition = $sConfig["SQLEDITION"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$StartupParameter='-T845'

."$dirSetup\scriptFunctions.ps1"

if ($sqlEdition -eq "SE") {

Write-Log -logfile $setupLog -level "Info" -message "Creating Audittrace directory."

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

$path = $server.InstallDataDirectory + "\AuditTraces"
# New-Item -ItemType directory -Path $path

Write-Log -logfile $setupLog -level "Info" -message "Startup Parameter is being set to $StartupParameter"

# Validation Code has to be created !!!

Write-Log -logfile $setupLog -level "Info" -message "Startup Parameter is currently set to $StartupParameter"

} 
