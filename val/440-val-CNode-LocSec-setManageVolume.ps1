# All

<#
Alternative way:
DECLARE @Res TABLE ( line NVARCHAR(255) NULL );
INSERT INTO @Res
EXEC xp_cmdshell 'WHOAMI /PRIV' ;
IF NOT EXISTS (SELECT * FROM @Res WHERE line LIKE 'SeLockMemoryPrivilege%' )
#>

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]

."$dirSetup\scriptFunctions.ps1"

$query = @"
    sp_readerrorlog 0, 1, 'Zeroing F:\_MP_DATA\MSSQL\Data\TestFileZero.mdf'
"@

$exitCode = (Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)).Text

if ($exitCode -eq $null)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Perform Volume Maintenance Privilage works fine"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Perform Volume Maintenance Privilage not working"
}
