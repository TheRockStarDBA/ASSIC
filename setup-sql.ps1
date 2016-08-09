<#

.SYNOPSIS
	Automated SQL Server Installation and Configuration script.
.DESCRIPTION
	The script installs and configures SQL Server using INI files
.NOTES
	File Name: setup-sql.ps1
	Author:	Andrzej Kozlowski andrzej@decktech.eu
	Version: 0.5
	Requires: Power Shell 3
.LINK
	http://decktech.eu
.EXAMPLE
	C:\> .\setup-sql.ps1 -template sqlTemplate.ini -pwdsa "xxx" -pwdsqlsvc "xxx" -pwdsqlagt "xxx" -pwdas "xxx"
.FUNCTIONALITY
	Supports SQL2008+
	Pre and Post actions not implemented
.PARAM pIniFile
	Key/value pair ini file
.PARAM pSAPWD
Password for sa user
.PARAM  pSQLSVCPASSWORD
Optional, password for SQL Server Service. If not provided pwdsa will be used.
.PARAM pAGTSVCPASSWORD
Optional, Password for SQL Server Agent. If not provided pwdsqlsvc will be used.
.PARAM pASSVCPASSWORD
Optional, Password for Analysis Services Service. If not provided either pwdsqlagt will be used.
#>

<# ****************************** Parameters prefix "p" ****************************** #>
[CmdletBinding(SupportsShouldProcess=$true)]
param
	(
		[Parameter(Position=0,Mandatory=$false)] [String]  $pIniFile,
		[Parameter(Position=1,Mandatory=$false)] [String]  $pSAPWD,
		[Parameter(Position=2,Mandatory=$false)] [String] $pSQLSVCPASSWORD = $pSAPWD,
		[Parameter(Position=3,Mandatory=$false)] [String] $pAGTSVCPASSWORD = $pSQLSVCPASSWORD,
		[Parameter(Position=4,Mandatory=$false)] [String] $pASSVCPASSWORD = $pAGTSVCPASSWORD,
		[Parameter(Position=5,Mandatory=$false)][switch] $SkipPre,
		[Parameter(Position=6,Mandatory=$false)][switch] $SkipPost,
		[Parameter(Position=7,Mandatory=$false)][switch] $SkipInstall,
		[Parameter(Position=8,Mandatory=$false)][switch] $ShowCmd
	)

<# ****************************** Main ****************************** #>
cls
# Starting script
$start = Get-Date

if( $pIniFile -and $pSAPWD )
{
# Setting Execution Policy
# Set-ExecutionPolicy RemoteSigned -force
$pathScript = $MyInvocation.MyCommand.Path
$dirScript = Split-Path $pathScript
."$dirScript\setupFunctions.ps1"
[System.Reflection.Assembly]::LoadWithPartialName("System.web")

# Read the template file and parse the parameters
cd $dirScript
$iniFile = Get-Content $pIniFile
$iniFile | Foreach-Object {$params = @{}} {$params[$_.split('=')[0]] = $_.split('=')[1]}

if ($params.SQLVERSION -NotLike '2008*' )
	{
		Import-Module sqlps -DisableNameChecking
	}
else
	{
	if (!(Get-PSSnapin | ?{$_.name -eq 'SqlServerProviderSnapin100'})) { Add-PSSnapin SqlServerProviderSnapin100 }
	if (!(Get-PSSnapin | ?{$_.name -eq 'SqlServerCmdletSnapin100'})) { Add-PSSnapin SqlServerCmdletSnapin100 }
	}

$serverName = gc env:computername

# Use default instance if none is provided

if ($params.INSTANCENAME -eq "")
    {
		$sqlServerName = $serverName
		$params.INSTANCENAME = "MSSQLSERVER"
	}

if ($params.FAILOVERCLUSTERNETWORKNAME -eq "")
    {
		if ($params.INSTANCENAME -ne 'MSSQLSERVER')
		{
			$sqlServerName = $serverName + '\' + $params.INSTANCENAME
		}
    }
else
	{
		$sqlServerName = $params.FAILOVERCLUSTERNETWORKNAME + '\' + $params.INSTANCENAME
	}

[String] $installationPath = $params.SQLDISTSVR + $params.SQLVERSION + "\" + $params.SQLEDITION

#Get the folder path and start building the Log file

$instanceName = $params.INSTANCENAME

$setupLog = join-path -path $dirScript -childPath "setupSql_$($serverName)_$instanceName.html"
if (Test-Path $setupLog) {
	Remove-Item $setupLog -Force
}

# Preparing parameters for pre- and post- scripts

[hashtable] $scriptConfig = New-Object hashtable

$scriptConfig.Add("SERVERNAME", $serverName)
$scriptConfig.Add("SQLSERVERNAME", $sqlServerName)
$scriptConfig.Add("INSTANCENAME", $params.INSTANCENAME)
$scriptConfig.Add("TCPPORT", $params.TCPPORT)
$scriptConfig.Add("SQLVERSION", $params.SQLVERSION)
$scriptConfig.Add("SQLEDITION", $params.SQLEDITION)
$scriptConfig.Add("DIRSCRIPT", $dirScript)
$scriptConfig.Add("SETUPLOG", $setupLog)
$scriptConfig.Add("SQLSVCACCOUNT", $params.SQLSVCACCOUNT)
$scriptConfig.Add("AGTSVCACCOUNT", $params.AGTSVCACCOUNT)
$scriptConfig.Add("MAXMEMORY", $params.MAXMEMORY)
$scriptConfig.Add("MAXDOP", $params.MAXDOP)
$scriptConfig.Add("FILLFACTOR", $params.FILLFACTOR)
$scriptConfig.Add("LOGFILES", $params.LOGFILES)
$scriptConfig.Add("ACTION", $params.ACTION)
$scriptConfig.Add("WINDOWSADMINACCOUNTS", $params.WINDOWSADMINACCOUNTS)

$scriptConfig.Add("LOGTOTABLE", $params.LOGTOTABLE)

$scriptConfig.Add("INVAPP", $params.INVAPP)
$scriptConfig.Add("INVGROUP", $params.INVGROUP)
$scriptConfig.Add("INVDESC", $params.INVDESC)
$scriptConfig.Add("INVLICTYPE", $params.INVLICTYPE)
$scriptConfig.Add("INVLICNUM", $params.INVLICNUM)
$scriptConfig.Add("INVVM", $params.INVVM)
$scriptConfig.Add("INVPROD", $params.INVPROD)
$scriptConfig.Add("INVTICKET", $params.INVTICKET)
$scriptConfig.Add("INVOWNER", $params.INVOWNER)

if ($params.TEMPDBFILES -gt 0) { $scriptConfig.Add("TEMPDBFILES", $params.TEMPDBFILES) }
if ($params.TEMPDBDATASIZE -gt 0) { $scriptConfig.Add("TEMPDBDATASIZE", $params.TEMPDBDATASIZE) }
if ($params.TEMPDBLOGSIZE -gt 0) { $scriptConfig.Add("TEMPDBLOGSIZE", $params.TEMPDBLOGSIZE) }
if ($params.TEMPDBFILEGROWTH -gt 0) { $scriptConfig.Add("TEMPDBFILEGROWTH", $params.TEMPDBFILEGROWTH) }

Write-Log -logfile $setupLog -level "Header" -message "SQL Installer Run on $serverName"
Write-Log -logfile $setupLog -level "Section" -message "Log File format"
Write-Log -logfile $setupLog -level "Info" -message "Sample Information"
Write-Log -logfile $setupLog -level "Notification" -message "Sample Notification"
Write-Log -logfile $setupLog -level "Warning" -message "Sample Warning"
Write-Log -logfile $setupLog -level "Error" -message "Sample Error"

Write-Log -logfile $setupLog -level "Section" -message "Start Parameters"

# Check if the executing user is running in an elevated shell and as an admin
$winIdentity = new-object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if ($isAdmin)
{

$scriptPath = $MyInvocation.MyCommand.Path
$scriptDir = Split-Path $ScriptPath
$errorStop = $false

	Write-Log -logfile $setupLog -level "Info" -message ("Script running as admin by {0}" -f $winIdentity.Identity.Name) | Out-Null

	# Pre-install
		if ($SkipPre -eq $false -and $errorStop -eq $false)
		{
			Write-Log -logfile $setupLog -level "Section" -message "Starting Pre-Install Steps"
			if ($pscmdlet.ShouldProcess("Execute Pre-Install Scripts", "Pre-Install"))
			{
				$preDir = $scriptDir + "\Pre"
				Invoke-Scripts -Param $scriptConfig -Folder $preDir
			}
			Write-Log -logfile $setupLog -level "Info" -message "Completed Pre-Install Steps"
		}
		else
		{
			Write-Log -logfile $setupLog -level "Section" -message "Skipping Pre-Install Steps"
		}

	# Install
	if ($SkipInstall -eq $false -and $errorStop -eq $false)
		{
			Write-Log -logfile $setupLog -level "Section" -message "Starting Install Steps"

			$sBaseDir = generateBaseDir
			switch ($params.ACTION)
				{
				"Install" 					{ $installCMD = createCmdInstall}
				"InstallFailoverCluster" 	{ $installCMD = createCmdInstall}
				"AddNode" 					{ $installCMD = createCmdAddNode}
				"RemoveNode" 				{ $installCMD = createCmdRemoveNode}
				}

			if ( $errorStop -eq $false )
				{
				if ($pscmdlet.ShouldProcess("Start SQL Installer Package", "Install SQL"))
				{
					Write-Log -logfile $setupLog -level "info" -message "$installCMD "
					if ($ShowCmd -eq $false) {
					Invoke-Expression $installCMD
					$exitCode = 0 # $lastexitcode
					} else {
					$installCMD
					$exitCode = 0
					}
				}

				if ($exitCode -eq 0)
				{
					Write-Log -logfile $setupLog -level "Info" -message "Completed SQL Server Install"
					$errorStop = $false
				}
				else
				{
					Write-Log -logfile $setupLog -level "Error" -message "SQL Server Install failed. Look into log for Errors."
					$errorStop = $true
				}
				}
		}
	else
		{
			Write-Log -logfile $setupLog -level "Section" -message "Skipping Install Steps"
		}

	# Post-install
		if ($SkipPost -eq $false -and $errorStop -eq $false)
		{
			Write-Log -logfile $setupLog -level "Section" -message "Starting Post-Install Steps"
			if ($pscmdlet.ShouldProcess("Execute Post-Install Scripts", "Post-Install"))
			{
				$IsSysAdmin = Invoke-SqlQuery -sqlQuery "select is_srvrolemember('sysadmin')" -sqlServerName $sqlServerName
				if($IsSysAdmin -eq 1)
				{
					$postDir = $scriptDir + "\Post"
					Invoke-Scripts -Param $scriptConfig -Folder $postDir
				}
				else
				{
					Write-Log -logfile $setupLog -level "Error" -message "The current user is not member of sysadmin group to run the Post-Install SQL Scripts"
				}
			}
			Write-Log -logfile $setupLog -level "Info" -message "Completed Post-Install Steps"
		}
		else
		{
			Write-Log -logfile $setupLog -level "Section" -message "Skipping Post-Install Steps"
		}

}
else
{
    # script running without admin rights
    Write-Log -logfile $setupLog -level "Error" -message "Script is running without Admin rights" | Out-Null
	throw "This script requires administrative rights."
}

# Capture end time
$end = Get-Date
$timeResult = ($end - $start)

Write-Log -logfile $setupLog -level "Section" -Message "Script Time Results"
Write-Log -logfile $setupLog -level "Info" -Message "Script Duration: $timeResult"

#Open the log file for the user
if ($pscmdlet.ShouldProcess("$setupLog", "Open Installer Log"))
	{
		$noie = @()
		try
		{
			Invoke-Item -ErrorAction SilentlyContinue -ErrorVariable noie -Path $setupLog
		}
		catch
		{
			$strResult = $_
			Write-Log -logfile $setupLog -level "Warning" -message "$file - Failed: $strResult"
		}
}
}
else

{
Write-Host "Incorrect Parameter Count use at least two: Template File and password for sa"
$cmdHelp = "
Help:
=====>
Mandatory:
  => Parameter 1 => pIniFile to specify template file
  => Parameter 2 => pSAPWD to set password for sa user, same password will be used for all service accounts.
=====>
Optional:
  => Parameter 3 => pSQLSVCPASSWORD to set password for SQLSVC account, same password will be used for other Service accounts
  => Parameter 4 => pAGTSVCPASSWORD to set password for AGTSVC account, same password will be used for Analysis Services Service
  => Parameter 5 => pASSVCPASSWORD to set password for ASSVC account.
=====>
Switches:
  => Switch 1 => SkipPre to skip pre-install steps
  => Switch 2 => SkipInstall to skip install steps
  => Switch 3 => SkipPost to skip post-install steps
	=> Switch 4 => ShowCmd to create installation CMD based on INI file
=====>
Examples
  => Example1 => ./setup-sql.ps1 <Template File> <SA Passowrd> <switches>
  => Example2 => ./setup-sql.ps1 'SQLServer.ini' 'secret' -skipInstall -skipPre
  => Example3 => ./setup-sql.ps1 'SQLServer.ini' 'secret' -skipInstall -skipPre"
  Write-Host $cmdHelp
}
