# All

param(
    [hashtable] $sConfig
)

$computerName = $sConfig["SERVERNAME"]
$portNumber = $sConfig["TCPPORT"]
$sqlservername = $sConfig["SQLSERVERNAME"]
$instanceName = $sConfig["INSTANCENAME"]
$SqlVersion = $sConfig["SQLVERSION"]
$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP port number is being set to $portNumber"

#Load the required assembly for 2008+
[system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null


#Get the ManagedComputer instance and set the protocol properties
$wmi = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $computerName
foreach ($ip in $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses) {
  $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses[$ip.name].IPAddressProperties["TcpPort"].value = "$portNumber"
  $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses[$ip.name].IPAddressProperties["TcpDynamicPorts"].value = [System.String]::Empty
}

#We need to commit the changes by calling the Alter method
$wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].Alter()

$curPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpPort"].value
$curDynPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].value
if ($curDynPort -eq "") { $curDynPort = "null" }

Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP IPAll port number is currently set to $curPort"
Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP IPAll Dynamic port number is currently set to $curDynPort"
