# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$windowsAdmins = $sConfig["WINDOWSADMINACCOUNTS"]
$serverName = $sConfig["SERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Validation => CHECKING local Administrators Group Membership"

$group = [ADSI]("WinNT://$serverName/Administrators,group")
$groups = @($group.psbase.Invoke("Members"))
$members = $groups | foreach {$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}

$windowsAdmins.Split(" ") | ForEach {
$windowsAdmin = ($_.replace("""", "")).replace("MUCMSPDOM\","")
$isMember = $members -contains $windowsAdmin

if ( $isMember -eq $true ) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => $windowsAdmin is member of local Administrators group"
    } else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> $windowsAdmin is not member of local Administrators group"
    }
}
