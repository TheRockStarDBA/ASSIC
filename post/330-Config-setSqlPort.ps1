# 2005,2008,2008R2,2012

$sConfig = $args[0]

$computerName = $sConfig["SERVERNAME"]
$portNumber = $sConfig["TCPPORT"]
$instanceName = $sConfig["SQLSERVERNAME"]
$SqlVersion = $configParams["SQLVERSION"]
$dirSetup = $configParams["DIRSCRIPT"]
$setupLog = $configParams["SETUPLOG"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP port number is being set to $portNumber"

#Load the required assembly for 2008+
[system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null


#Get the ManagedComputer instance and set the protocol properties
$wmi = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $computerName
$wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpPort"].value = "$portNumber"
$wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].value = [System.String]::Empty

#We need to commit the changes by calling the Alter method
$wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].Alter()

#Verify the results and write them to the log
$curPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpPort"].value
$curDynPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].value

Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP port number is currently set to $curPort"
Write-Log -logfile $setupLog -level "Info" -message "The SQL TCP Dynamic port number is currently set to $curDynPort"
