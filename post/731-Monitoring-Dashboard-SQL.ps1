# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

start-sleep 5
Write-Log -logfile $setupLog -level "Info" -message "Executing Performance Dashboard Script"
Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql" -querytimeout ([int]::MaxValue)
Write-Log -logfile $setupLog -level "Info" -message "Script Succeeded with $exitCode"

# $exitCode = Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql" -querytimeout ([int]::MaxValue)
#if ($exitCode -eq "Command(s) completed successfully.")
#{
#  Write-Log -logfile $setupLog -level "Info" -message "Script Succeeded with $exitCode"
#}
#else
#{
#  Write-Log -logfile $setupLog -level "Warning" -message "Script Failed with $exitCode"
#}
