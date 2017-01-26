# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlServername = $sConfig["SQLSERVERNAME"]
$sqlVersion = $sConfig["SQLVERSION"]

."$dirSetup\scriptFunctions.ps1"

Write-Log -logfile $setupLog -level "Info" -message "Creating System Integrity Job"

# [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null

# Connect to the specified instance
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName

# Variables

$jobName="OLA SYSTEMDB IntegrityCheck"
$trimmedJobName = $jobName.Replace(" ","_")

$sqlVersionSplit = '2008','2008R2','2012'

if ( $sqlVersionSplit -contains $sqlVersion  ) {
		$log = "$($server.InstallDataDirectory)\Log\$trimmedJobName.txt"
} else {
		$log = "$(ESCAPE_SQUOTE(SQLLOGDIR))\$trimmedJobName_$(ESCAPE_SQUOTE(JOBID))_$(ESCAPE_SQUOTE(STEPID))_$(ESCAPE_SQUOTE(STRTDT))_$(ESCAPE_SQUOTE(STRTTM)).txt"
}

$strJobStep1 = @'
sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "EXECUTE [dbo].[DatabaseIntegrityCheck] @Databases = 'SYSTEM_DATABASES', @LogToTable = 'Y'" -b
'@

if ($server.JobServer.Jobs[$jobName])
{
	$server.JobServer.Jobs[$jobName].Drop()
}

$job = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Agent.Job -ArgumentList $server.JobServer, $jobName
$job.OwnerLoginName = "sa"
$job.Category = "OLA Database Maintenance"
$job.Description = "Source: https://ola.hallengren.com"

$job.Create()
$job.ApplyToTargetServer($sqlServerName)

# Step 1
$jobStep = New-Object Microsoft.SqlServer.Management.Smo.Agent.JobStep($job, "SYSTEMDB IntegrityCheck")
$jobStep.Subsystem = [Microsoft.SqlServer.Management.Smo.Agent.AgentSubSystem]::CmdExec
$jobStep.Command = $strJobStep1
$jobStep.OnSuccessAction = [Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction]::QuitWithSuccess
$jobStep.OnFailAction = [Microsoft.SqlServer.Management.Smo.Agent.StepCompletionAction]::QuitWithFailure
$jobStep.OutputFileName = $log
$jobStep.JobStepFlags = 2
$jobStep.Create()

$schedulename = "daily at 22:04"
 $now = Get-Date -format "MM/dd/yyyy"
 $schedule = New-Object Microsoft.SqlServer.Management.SMO.Agent.JobSchedule($job, $schedulename)
 $schedule.FrequencyTypes = [Microsoft.SqlServer.Management.SMO.Agent.FrequencyTypes]::Daily
 $schedule.FrequencyInterval = 1
 $timespan = New-TimeSpan -hours 22 -minutes 04
 $schedule.ActiveStartTimeofDay = $timespan
 $schedule.ActiveStartDate = $now
 $schedule.Create()


Write-Log -logfile $setupLog -level "Info" -message "Finishing System Integrity Job"
