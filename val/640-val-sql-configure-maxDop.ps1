# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$maxDop = $sConfig["MAXDOP"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
	    SELECT * FROM [master]..[sysconfigures] where comment = 'maximum degree of parallelism'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value

if ($exitCode -eq $maxDop)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => max degree of parallelism set to $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> max degree of parallelism set to $exitCode"
}
