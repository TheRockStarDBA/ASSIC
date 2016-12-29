Function generateBaseDir()
{
	switch ($params.SQLVERSION) {
		"2008" { $fBaseDir = "MSSQL10." + $params.INSTANCENAME }
		"2012" { $fBaseDir = "MSSQL11." + $params.INSTANCENAME }
		"2014" { $fBaseDir = "MSSQL12." + $params.INSTANCENAME }
		"2016" { $fBaseDir = "MSSQL13." + $params.INSTANCENAME }
	}
	return $fBaseDir

}

Function createCmdInstall()
{

	[String] $installCMD=""

	$installCMD = $installationPath + "\Setup.exe /q"
	$installCMD=$installCMD + " /ACTION=" + $params.ACTION
	$installCMD=$installCMD + " /FEATURES=" + $params.FEATURES
	$installCMD=$installCMD + " /INSTANCENAME=" + $params.INSTANCENAME
	$installCMD=$installCMD + " /SAPWD='" + $pSAPWD + "'"
	$installCMD=$installCMD + " /SQLSYSADMINACCOUNTS=" + $params.SQLSYSADMINACCOUNTS
	$installCMD=$installCMD + " /SQLSVCACCOUNT=" + $params.SQLSVCACCOUNT
	$installCMD=$installCMD + " /SQLSVCPASSWORD='" + $pSQLSVCPASSWORD + "'"
	$installCMD=$installCMD + " /AGTSVCACCOUNT=" + $params.AGTSVCACCOUNT
	$installCMD=$installCMD + " /AGTSVCPASSWORD='" + $pAGTSVCPASSWORD + "'"
	$installCMD=$installCMD + " /SQLCOLLATION=" + $params.SQLCOLLATION

	# Directories

	$installCMD=$installCMD + " /INSTALLSQLDATADIR='" + $params.INSTALLSQLDATADIR  + "\'"

	if ( $params.SQLVERSION -ne "2008" -or $params.SQLVERSION -ne "2008R2" ) {
		$installCMD=$installCMD + " /IACCEPTSQLSERVERLICENSETERMS=" + $params.IACCEPTSQLSERVERLICENSETERMS
	}

	if ( $params.PCUSOURCE.Length -gt 0 ) {
		$installCMD=$installCMD + " /PCUSOURCE=" + $params.PCUSOURCE
	}

	if ( $params.CUSOURCE.Length -gt 0 ) {
		$installCMD=$installCMD + " /CUSOURCE=" + $params.CUSOURCE
	}

	if ( $params.SQLUSERDBDIR.Length -eq 2 ) {
		$installCMD=$installCMD + " /SQLUSERDBDIR='" + $params.SQLUSERDBDIR + "\" + $sBaseDir + "\MSSQL\Data'"
	} elseif ( $params.SQLUSERDBDIR.Length -gt 2 ) {
		$installCMD=$installCMD + " /SQLUSERDBDIR='" + $params.SQLUSERDBDIR + "\MSSQL\Data'"
	}

	if ( $params.SQLUSERDBLOGDIR.Length -eq 2 ) {
		$installCMD=$installCMD + " /SQLUSERDBLOGDIR='" + $params.SQLUSERDBLOGDIR + "\" + $sBaseDir + "\MSSQL\Data'"
	} elseif ( $params.SQLUSERDBLOGDIR.Length -gt 2 ) {
		$installCMD=$installCMD + " /SQLUSERDBLOGDIR='" + $params.SQLUSERDBLOGDIR + "\MSSQL\Data'"
	}

	if ( $params.SQLTEMPDBDIR.Length -eq 2 ) {
		$installCMD=$installCMD + " /SQLTEMPDBDIR='" + $params.SQLTEMPDBDIR + "\" + $sBaseDir + "\MSSQL\Data'"
	} elseif ( $params.SQLTEMPDBDIR.Length -gt 2 ) {
		$installCMD=$installCMD + " /SQLTEMPDBDIR='" + $params.SQLTEMPDBDIR + "\MSSQL\Data'"
	}

	if ( $params.SQLTEMPDBLOGDIR.Length -eq 2 ) {
		$installCMD=$installCMD + " /SQLTEMPDBLOGDIR='" + $params.SQLTEMPDBLOGDIR + "\" + $sBaseDir + "\MSSQL\Data'"
	} elseif ( $params.SQLTEMPDBLOGDIR.Length -gt 2 ) {
		$installCMD=$installCMD + " /SQLTEMPDBLOGDIR='" + $params.SQLTEMPDBLOGDIR + "\MSSQL\Data'"
	}

	if ( $params.SQLBACKUPDIR.Length -eq 2 ) {
		$installCMD=$installCMD + " /SQLBACKUPDIR='" + $params.SQLBACKUPDIR + "\" + $sBaseDir + "\MSSQL\Backup'"
	} elseif ( $params.SQLBACKUPDIR.Length -gt 2 ) {
		$installCMD=$installCMD + " /SQLBACKUPDIR='" + $params.SQLBACKUPDIR + "\MSSQL\Backup'"
	}

	if ($params.ACTION -ne "Install") {

	# Cluster specific parameters

		if (( $params.FAILOVERCLUSTERNETWORKNAME.Length -gt 0 ) -and ( $params.FAILOVERCLUSTERGROUP.Length -gt 0 ) -and ( $params.FAILOVERCLUSTERIPADDRESSES.Length -gt 0 ))
			{
			$installCMD=$installCMD + " /FAILOVERCLUSTERNETWORKNAME=" + $params.FAILOVERCLUSTERNETWORKNAME
			$installCMD=$installCMD + " /FAILOVERCLUSTERGROUP=" + $params.FAILOVERCLUSTERGROUP
			$installCMD=$installCMD + " /FAILOVERCLUSTERIPADDRESSES=" + $params.FAILOVERCLUSTERIPADDRESSES
			if ( $params.FAILOVERCLUSTERDISKS.Length -gt 0 )
				{
				$installCMD=$installCMD + " /FAILOVERCLUSTERDISKS=" + $params.FAILOVERCLUSTERDISKS
				}
			}
		else
			{
			Write-Log -logfile $setupLog -level "Error" -message "SQL Server Install failed - one or more cluster parameters missing"
			$errorStop = $true
			}
	}

	$installCMD=$installCMD + "`n"
	return $installCMD
}

Function createCmdAddNode()
{

	$installCMD=""
	$installCMD = $installationPath + "\Setup.exe /q /ACTION=AddNode "
	$installCMD=$installCMD + " /INSTANCENAME=" + $params.INSTANCENAME
	$installCMD=$installCMD + " /SQLSVCACCOUNT=" + $params.SQLSVCACCOUNT
	$installCMD=$installCMD + " /SQLSVCPASSWORD='" + $pSQLSVCPASSWORD + "'"
	$installCMD=$installCMD + " /AGTSVCACCOUNT=" + $params.AGTSVCACCOUNT
	$installCMD=$installCMD + " /AGTSVCPASSWORD='" + $pAGTSVCPASSWORD + "'"

	if ( $params.SQLVERSION -ne "2008" -or $params.SQLVERSION -ne "2008R2" ) {
		$installCMD=$installCMD + " /IACCEPTSQLSERVERLICENSETERMS=" + $params.IACCEPTSQLSERVERLICENSETERMS
	}

    if ( $params.PCUSOURCE.Length -gt 0 ) {
        $installCMD=$installCMD + " /PCUSOURCE=" + $params.PCUSOURCE
    }

    if ( $params.CUSOURCE.Length -gt 0 ) {
        $installCMD=$installCMD + " /CUSOURCE=" + $params.CUSOURCE
    }

	$installCMD=$installCMD + "`n"
	return $installCMD
}

Function createCmdRemoveNode()
{

	$installCMD=""
	$installCMD = $installationPath + "\Setup.exe /q /ACTION=RemoveNode "
	$installCMD=$installCMD + " /INSTANCENAME=" + $params.INSTANCENAME

	$installCMD=$installCMD + "`n"
	return $installCMD
}

Function Invoke-Powershell
{
	param
	(
		[Parameter(Position=0, Mandatory=$true)] [string] $psScript,
		[Parameter(Position=1, Mandatory=$true)] $configParams
	)

	return Invoke-Expression -Command "$psScript `$configParams"
}

Function Invoke-SqlScript
{
	param
	(
		[Parameter(Position=0, Mandatory=$true)] [string] $sqlScript,
		[Parameter(Position=1, Mandatory=$true)] [AllowEmptyString()] [string] $sqlServerName,
       	[Parameter(Position=3, Mandatory=$false)] [string] $Dbname = "master"
	)

    try
	{
		Invoke-Sqlcmd -InputFile $sqlScript -ServerInstance $sqlServerName -Database $Dbname
		$exitCode = "Command(s) completed successfully."
	}
	catch [System.Exception]
	{
		$exitCode = $_.Exception
	}

	return $exitCode
}

Function Invoke-SqlQuery
{
	param
	(
		[Parameter(Position=0, Mandatory=$true)] [string] $sqlQuery,
		[Parameter(Position=1, Mandatory=$true)] [AllowEmptyString()] [string] $sqlServerName,
       	[Parameter(Position=3, Mandatory=$false)] [string] $Dbname = "master"
	)

    try
	{
		$retVal = (Invoke-Sqlcmd -Query $sqlQuery -ServerInstance $sqlServerName -Database $Dbname)[0]
		$exitCode = "Command(s) completed successfully."
	}
	catch [System.Exception]
	{
		$exitCode = $_.Exception
	}

	return $retVal
}

Function Invoke-Scripts
{
	param
	(
		[Parameter(Position=0, Mandatory=$true)][hashtable] $Param,
		[Parameter(Position=1, Mandatory=$true)] $Folder
	)

	$SqlServerName = $Param["SQLSERVERNAME"]
	[string] $fSqlVersion = $Param["SQLVERSION"]

	if ($Folder.Contains("Pre"))
	{
		Write-Log -logfile $setupLog -level "Info" -message ("PreScripts: " + $Folder)
		[array] $scripts = get-childitem -path $Folder -Exclude _* | Where-Object  { $_.Extension -eq ".ps1" -or $_.Extension -eq ".sql" }
        $count = $scripts.Count
		$message = "Applying $count Pre Scripts"
	}
	if ($Folder.Contains("Post"))
	{
		Write-Log -logfile $setupLog -level "Info" -message ("PostScripts: " + $Folder)
		[array] $scripts = get-childitem -path $Folder -Exclude _* | Where-Object  { $_.Extension -eq ".ps1" -or $_.Extension -eq ".sql" }
		$count = $scripts.Count
        $message = "Applying $count Post Scripts"
	}

    if ($Folder.Contains("Val"))
	{
		Write-Log -logfile $setupLog -level "Info" -message ("ValScripts: " + $Folder)
		[array] $scripts = get-childitem -path $Folder -Exclude _* | Where-Object  { $_.Extension -eq ".ps1" -or $_.Extension -eq ".sql" }
		$count = $scripts.Count
        $message = "Applying $count Val Scripts"
	}

	$scripts = $scripts | Sort-Object

	Write-Log -logfile $setupLog -level "Section" -message $message

	# Executing scripts in loop

	Write-Log -logfile $setupLog -level "Info" -message "==================================================>"

	foreach ($script in $scripts)
	{
		# Checking first line for supported SQL Version (# 2008,2008R2,2012,2014) or (-- 2008,2008R2,2012,2014)
		[string] $supRawVersion = Get-Content -Path $script.FullName -TotalCount 1

		# Cleaning off the # and -- from variable, and splitting
		[array] $supVersion = $supRawVersion.Replace('#', '').Replace('-','').Trim().Split(',')

		if ($supVersion -contains $fSqlVersion -or $supVersion -contains "All") # Supported by SQL Version ?
			{
				if ($script.Extension -eq ".sql")
				{
					# Write the script name and results to the log
					Write-Log -logfile $setupLog -level "Info" -message "Starting SQL Script: $script"
					$exitCode = Invoke-SQLScript -sqlScript $script.FullName -sqlServerName $SqlServerName

					if ($exitCode -eq "Command(s) completed successfully.")
					{
						Write-Log -logfile $setupLog -level "Info" -message "Script $script finished with $exitCode"
					}
					elseif ($exitCode -like '*A transport-level error has occurred when sending the request to the server*')
					{
						$exitCode = Invoke-SQLScript -sqlScript $script.FullName -sqlServerName $SqlServerName

						if ($exitCode -eq "Command(s) completed successfully.")
						{
							Write-Log -logfile $setupLog -level "Info" -message "Script $script Succeeded with $exitCode"
						}
						else
						{
							Write-Log -logfile $setupLog -level "Warning" -message "Script $script Failed with $exitCode"
						}
					}
					else
					{
						Write-Log -logfile $setupLog -level "Warning" -message "Script $script Failed with $exitCode"
					}
				}
				if ($script.Extension -eq ".ps1")
				{
					# Write the script name and results to the log
					Write-Log -logfile $setupLog -level "Info" -message "Starting PowerShell Script: $script"

					try
					{
						$exitCode = Invoke-Powershell -psScript $script.FullName -configParams $Param

						if ($exitCode -eq "" -or $exitCode -eq $null -or $exitCode[-1] -eq 0)
						{
							Write-Log -logfile $setupLog -level "Info" -message "Script $script Succeeded with empty exit code."
						}
						else
						{
							Write-Log -logfile $setupLog -level "Error" -message "Script $script finished with Exit Code: $exitCode"
						}
					}
					catch
					{
						$exitCode = $_
						Write-Log -logfile $setupLog -level "Warning" -message "Script $script Failed with $exitCode"
					}
				}
				Write-Log -logfile $setupLog -level "Info" -message "==================================================>"
			}
		else
			{
				Write-Log -logfile $setupLog -level "Attention" -message ("Skipping Script " + $script + ": SQL Version not supported")
			}
	}
	Write-Log -logfile $setupLog -level "Info" -message "Standard Scripts Complete"
}
