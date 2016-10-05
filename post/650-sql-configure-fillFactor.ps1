# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$fillFactor = $sConfig["FILLFACTOR"]

."$dirSetup\scriptFunctions.ps1"

if (!$fillFactor) {
  $fillFactor  = 90
  }

Write-Log -logfile $setupLog -level "Info" -message "fill factor is being set to $fillFactor"

$query = @"
  exec sp_configure 'show advanced options', 1;
  RECONFIGURE WITH OVERRIDE;
  exec sp_configure 'fill factor', $fillFactor;
  RECONFIGURE;
"@

# Write-Host $query
Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "Info" -message "fill factor is currently set to $fillFactor"
