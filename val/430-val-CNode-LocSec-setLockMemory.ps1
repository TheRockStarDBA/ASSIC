# All

<#
Alternative way:
DECLARE @Res TABLE ( line NVARCHAR(255) NULL );
INSERT INTO @Res
EXEC xp_cmdshell 'WHOAMI /PRIV' ;
IF NOT EXISTS (SELECT * FROM @Res WHERE line LIKE 'SeLockMemoryPrivilege%' )
IF NOT EXISTS (SELECT * FROM @Res WHERE line LIKE 'SeManageVolumePrivilege%' )
#>

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
    sp_readerrorlog 0, 1, 'Using locked pages'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).Text

if ($exitCode -match 'Using locked pages')
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => The Lock Memory Privilage: $exitCode"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> The Lock Memory Privilage missing: $exitCode"
}
