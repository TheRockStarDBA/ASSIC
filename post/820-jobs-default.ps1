# 2008,2008R2,2012,2014

$sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Modifying MS Default Job"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName
$agent = $server.JobServer

# Variables

$jobNewName="Microsoft syspolicy_purge_history"
$jobNewCategory="Microsoft Default"

 $job = $server.JobServer.Jobs | Where-Object {$_.Name -eq "syspolicy_purge_history"};
    $job.Category = $jobNewCategory
    $job.rename($jobNewName)
    $job.Alter()

Write-Log -logfile $setupLog -level "Info" -message "Modifying MS Default Job Finished"
