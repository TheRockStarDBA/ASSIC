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

If (Test-Path "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql") {
    try
    {
        Invoke-Sqlcmd -ServerInstance $SqlServerName -InputFile "C:\Program Files (x86)\Microsoft SQL Server\110\Tools\Performance Dashboard\setup.sql" -querytimeout ([int]::MaxValue)
        # $exitCode = "Command(s) completed successfully."
        Write-Log -logfile $setupLog -level "Info" -message "Script Finished: $exitCode"
    }
    catch [System.Exception]
    {
        $exitCode = $_.Exception
    }
} Else {
    Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Performance Dashboard binaries not found !"
    $exitCode = 11
}

return $exitCode
