# 2008,2008R2,2012,2014

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

# Check Starting port for Dynamic Range
netsh int ipv4 show dynamicport tcp
$dynamicStartPort = (((netsh int ipv4 show dynamicport tcp) | Select-String -Pattern "Start Port") -split ": ")[1]

if ( $portNumber -lt $dynamicStartPort) {
    #Load the required assembly for 2008+
    [system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | out-null
    #Get the ManagedComputer instance and set the protocol properties
    $wmi = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $computerName
    $issue = 0
    #Verify the results and write them to the log
    foreach ($ip in $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses) {
        $ipName = $ip.name
        $curPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses[$ip.name].IPAddressProperties["TcpPort"].value
        $curDynPort = $wmi.ServerInstances["$instanceName"].ServerProtocols["Tcp"].IPAddresses[$ip.name].IPAddressProperties["TcpDynamicPorts"].value

        if ($curDynPort -ne "") {
            if ($curDynPort -eq "") { $curDynPort = "null" }
            Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> The SQL TCP $ipName Dynamic Port has value: $curDynPort"
            $issue += 1
        }
        if ($curPort -ne $portNumber) {
            if ($curPort -eq "") { $curPort = "null" }
            Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> The SQL TCP $ipName Port has wrong value: $curPort"
            $issue += 1
        }
    }
    if ( $issue -eq 0) {
        Write-Log -logfile $setupLog -level "Info" -message "Validating OK => All SQL Ports have correct values"
    } else {
        Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Found $Issue errors with Port setup"
    }
} else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> SQL Ports within Dynamic Range!"
}
