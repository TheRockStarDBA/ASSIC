# 2008

$sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlEdition = $sConfig["SQLEDITION"]

$StartupParameter='-T845'

."$dirSetup\scriptFunctions.ps1"

if ($sqlEdition -eq "SE") {

Write-Log -logfile $setupLog -level "Info" -message "Startup Parameter is being set to $StartupParameter"

$hklmRootNode = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server"

$props = Get-ItemProperty "$hklmRootNode\Instance Names\SQL"
$instances = $props.psobject.properties | ?{$_.Value -like 'MSSQL*'} | select Value

$instances | %{
    $inst = $_.Value;
    $regKey = "$hklmRootNode\$inst\MSSQLServer\Parameters"
    $props = Get-ItemProperty $regKey
    $params = $props.psobject.properties | ?{$_.Name -like 'SQLArg*'} | select Name, Value
    #$params | ft -AutoSize
    $hasFlag = $false
    foreach ($param in $params) {
        if($param.Value -eq $StartupParameter) {
            $hasFlag = $true
            break;
        }
    }
    if (-not $hasFlag) {
        "Adding $StartupParameter"
        $newRegProp = "SQLArg"+($params.Count)
        Set-ItemProperty -Path $regKey -Name $newRegProp -Value $StartupParameter
    } else {
        "$StartupParameter already set"
    }
}

Write-Log -logfile $setupLog -level "Info" -message "Startup Parameter is currently set to $StartupParameter"

} else {

Write-Log -logfile $setupLog -level "Info" -message "Startup Parameter $StartupParameter not needed"

}
