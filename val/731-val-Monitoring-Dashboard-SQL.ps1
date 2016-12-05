# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
    SELECT COUNT(name) as value FROM msdb.sys.schemas WHERE name = 'MS_PerfDashboard'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value

if ($exitCode -ne 0) {
    Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Monitoring Dashboard Database Objects Created Succesfully"
} else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Monitoring Dashboard Database Objects Creation Failed"
}
