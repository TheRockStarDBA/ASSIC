# all

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$windowsAdmins = $sConfig["WINDOWSADMINACCOUNTS"]
$serverName = $sConfig["SERVERNAME"]

$windowsAdmins

."$dirSetup\scriptFunctions.ps1"

$windowsAdmins.Split(" ") | ForEach {
    Write-Log -logfile $setupLog -level "Info" -message "$_ is being set as members of local Administrators Group"
    ([ADSI]"WinNT://$serverName/Administrators,group").Invoke('Add', "WinNT://$_")
 }

Write-Log -logfile $setupLog -level "Info" -message "$windowsAdmins are currently members of local Administrators Group"
