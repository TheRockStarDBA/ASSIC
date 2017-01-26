# All

param(
    [hashtable] $sConfig
)

# $sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Stored Procedures supporting OLA are being created"

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

$sqlVariable = "CreateJobs='N'"

$exitCode = Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "$dirSetup\Tools\MaintenanceSolution.sql" -Variable $sqlVariable -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "info" -message "Stored Procedures supporting OLA are created returning: $exitCode"
