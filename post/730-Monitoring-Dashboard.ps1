# 2008,2008R2,2012,2014

$sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Installing SQLServer 2012 Performance Dashboard"

$fileExe = "$dirSetup\Tools\SQLServer2012_PerformanceDashboard.msi"
& msiexec /quiet /i $fileExe
Write-Log -logfile $setupLog -level "Info" -message "Performance Dashboard is currently installed"

$exitCode = Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql" -querytimeout ([int]::MaxValue)

if ($exitCode -eq "Command(s) completed successfully.")
{
  Write-Log -logfile $setupLog -level "Info" -message "Script Succeeded with $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Warning" -message "Script Failed with $exitCode"
}
