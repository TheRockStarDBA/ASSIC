# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Validation => CHECKING Trace Flag setup"

$query = @"
    DBCC TRACESTATUS() WITH NO_INFOMSGS
"@

# Write-Host $query
$traces = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue))
$i = 0
foreach ($trace in $traces)
{
	$traceFlag = $trace.TraceFlag
	$traceStatus = $trace.Status
	$traceGlobal = $trace.Global
	if ( $traceFlag -eq 1118)
	{
        $i = 1
		if ( $traceStatus -eq 1 -and $traceGlobal -eq 1) {
			Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Trace $traceFlag has status $traceStatus and global set to $traceGlobal"
			}
			else {
			Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Trace $traceFlag has status $traceStatus and global set to $traceGlobal"
			}
        break
	}
}
if ( $i -eq 0) {
Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Trace 1118 has not been set up"
}
