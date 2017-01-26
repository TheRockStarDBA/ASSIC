# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$maxServerMemory = $sConfig["MAXMEMORY"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
    SELECT * FROM [master]..[sysconfigures] where comment = 'Maximum size of server memory (MB)'
"@

#get the amount of total memory (MB)
$wmi = Get-WmiObject Win32_OperatingSystem
$totalMemory = [Math]::Round(($wmi.TotalVisibleMemorySize / 1024))

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value
$osMemory = $totalMemory - $exitCode

if ( $osMemory -ge 4096 ) {
      Write-Log -logfile $setupLog -level "Info" -message "Validating OK => OS Memory: $osMemory"
} else {
      Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> OS Memory: $osMemory"
}

if ($exitCode -eq $maxServerMemory)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => max server memory set to $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> max server memory set to $exitCode"
}
