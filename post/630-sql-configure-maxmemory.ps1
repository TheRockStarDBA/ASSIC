# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$maxServerMemory = $sConfig["MAXMEMORY"]

."$dirSetup\scriptFunctions.ps1"

#get the amount of total memory (MB)
$wmi = Get-WmiObject Win32_OperatingSystem
$totalMemory = ($wmi.TotalVisibleMemorySize / 1024)

if (!$maxServerMemory) {

  # Conditional logic to determine the amount of total physical memory and the calculation for configuring SQL Server maximum memory.
  If ($totalMemory -ge  "8192") {
    $maxServerMemory  = [Math]::Round($totalMemory  - ((($totalMemory  / 8192) * 1024) + 2048))
  } Else {
    $maxServerMemory  = 2048
  }

}

Write-Log -logfile $setupLog -level "Info" -message "max server memory is being set to $maxServerMemory"

$query = @"
  exec sp_configure 'show advanced options', 1;
  RECONFIGURE;
  exec sp_configure 'max server memory', $maxServerMemory;
  RECONFIGURE;
"@

# Write-Host $query
Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "Info" -message "max server memory is currently set to $maxServerMemory"
