# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$maxDop = $sConfig["MAXDOP"]

."$dirSetup\scriptFunctions.ps1"

#get a collection of physical processors
[array] $procs = Get-WmiObject Win32_Processor
$totalProcs = $procs.Count
$totalCores = 0

#count the total number of cores across all processors
foreach ($proc in $procs)
{
    $totalCores = $totalCores + $proc.NumberOfCores
}

if (!$maxDop) {

  If ($totalCores -ge  8) {
    $maxDop  = 8
  } Else {
    [int]$maxDop  = $totalCores / 2
  }

}

Write-Log -logfile $setupLog -level "Info" -message "max degree of parallelism is being set to $maxDop"

$query = @"
  exec sp_configure 'show advanced options', 1;
  RECONFIGURE WITH OVERRIDE;
  exec sp_configure 'max degree of parallelism', $maxDop;
  RECONFIGURE;
"@

# Write-Host $query
Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "Info" -message "max degree of parallelism is currently set to $maxDop"
