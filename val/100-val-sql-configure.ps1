# 2008,2008R2,2012,2014

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Validation => CHECKING show advanced options"

$query = @"
    SELECT value FROM [master]..[sysconfigures] where comment = 'show advanced options'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value

if ($exitCode -eq "1")
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => show advanced options: $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> show advanced options: $exitCode"
}

Write-Log -logfile $setupLog -level "Info" -message "Validation => CHECKING command shell"

$query = @"
    SELECT value FROM [master]..[sysconfigures] where comment = 'Enable or disable command shell'
"@

# Write-Host $query
$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).value

if ($exitCode -eq "1")
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => command shell: $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> command shell: $exitCode"
}
