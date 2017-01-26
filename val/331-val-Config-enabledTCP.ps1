# All

param(
    [hashtable] $sConfig
)

$computerName = $sConfig["SERVERNAME"]
$instanceName = $sConfig["INSTANCENAME"]
$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]

."$dirSetup\scriptFunctions.ps1"

#Load the required assembly for 2008+
[system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
#Get the ManagedComputer instance and set the protocol properties
$wmi = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $computerName
$enableTCP = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].ProtocolProperties["Enabled"].Value

if ( $enableTCP -eq $true) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => TCP/IP Protocol is enabled"
} else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> TCP/IP Protocol is disabled"
}
