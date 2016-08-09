# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

# $sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]
$logTo = $sConfig["LOGTOTABLE"]

."$dirSetup\scriptFunctions.ps1"

  if (!$logTo) {
    $logTo  = 'N'
    }

Write-Log -logfile $setupLog -level "Info" -message "Stored Procedures supporting OLA are being created"

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

$sqlVariable = "CreateJobs='N'", "LogToTable='$logTo'"

$exitCode = Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "$dirSetup\Tools\MaintenanceSolution.sql" -Variable $sqlVariable -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "info" -message "Stored Procedures supporting OLA are created returning: $exitCode"
