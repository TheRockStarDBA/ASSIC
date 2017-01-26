# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$fillFactor = $sConfig["FILLFACTOR"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
	    SELECT * FROM [master]..[sysconfigures] where comment = 'Default fill factor percentage'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value

if ($exitCode -eq $fillFactor)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => fill factor set to $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> fill factor set to $exitCode"
}
