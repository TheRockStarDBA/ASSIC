# 2008,2008R2,2012,2014

$sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]
$instanceName = $sConfig["INSTANCENAME"]
$sqlSvc = $sConfig["SQLSVCACCOUNT"]
$agtSvc = $sConfig["AGTSVCACCOUNT"]

."$dirSetup\scriptFunctions.ps1"

if ($instanceName -eq "MSSQLSERVER") {
  $SQLsvc = $instanceName
  $AGTsvc = "SQLSERVERAGENT"
} else {
  $SQLsvc = "MSSQL$" + $instanceName
  $AGTsvc = "SQLAgent$" + $instanceName
}

Write-Log -logfile $setupLog -level "Info" -message "Restarting the SQL Services: $SQLsvc, $AGTsvc"

get-service | ?{$_.Name -eq $SQLsvc} | restart-service -force
get-service | ?{$_.Name -eq $AGTsvc} | restart-service -force


Write-Log -logfile $setupLog -level "Info" -message "SQL Services: have been recycled: $SQLsvc, $AGTsvc"
