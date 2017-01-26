# All

param(
    [hashtable] $sConfig
)

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

."$dirSetup\scriptFunctions.ps1"

$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName
$dbname = "model"
$db = $server.Databases[$dbname]
$dbRecovery = $db.RecoveryModel
if ($dbRecovery -like "Simple")
{
  Write-Log -logfile $setupLog -level "Info" -message "Validating OK => DB Model has Recovery: $dbRecovery"
}
else
{
  Write-Log -logfile $setupLog -level "Error" -message "ERROR ===>>> DB Model has Recovery: $dbRecovery"
}
