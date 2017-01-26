# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

$tempdbFiles = $sConfig["TEMPDBFILES"]
# $tempdbDataSize = $sConfig["TEMPDBDATASIZE"]
# $tempdbLogSize = $sConfig["TEMPDBLOGSIZE"]
# $tempdbFileGrowth = $sConfig["TEMPDBFILEGROWTH"]

."$dirSetup\scriptFunctions.ps1"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName
$dbname = "tempdb"
$db = $server.Databases[$dbname]
$tempfiles = ($db.FileGroups.files | measure).count
if ($tempfiles -eq $tempdbFiles)
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => Number of tempdb files: $tempfiles"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> Number of tempdb files: $tempfiles"
}
