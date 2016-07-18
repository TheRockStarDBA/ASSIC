# 2008,2008R2,2012,2014

<#
.NOTES
Version History
v1.0 - Michael Wells - Initial release
v2.0 - Andrzej Kozlowski -Improvements:
	Fixing filesize
	Adding tempdb log file directory: @log_path
	Removing $maxFileGrowthSizeMB
	Adding Location change for data and log file
#>

$maxFileCount = 8
$maxLogFileInitialSizeMB = 4096
$maxFileInitialSizeMB = 4096
$defaultFileGrowth = 10
$coreMultiplier = 1.0

$sConfig = $args[0]

$dirSetup = $sConfig["DIRSCRIPT"]
$setupLog = $sConfig["SETUPLOG"]
$sqlservername = $sConfig["SQLSERVERNAME"]

[int] $tempdbFiles = $sConfig["TEMPDBFILES"]
[int] $tempdbDataSize = $sConfig["TEMPDBDATASIZE"]
[int] $tempdbLogSize = $sConfig["TEMPDBLOGSIZE"]
[int] $tempdbFileGrowth = $sConfig["TEMPDBFILEGROWTH"]

."$dirSetup\scriptFunctions.ps1"

if (!$tempdbFiles) {

#get a collection of physical processors
[array] $procs = Get-WmiObject Win32_Processor
$totalProcs = $procs.Count
$totalCores = 0

#count the total number of cores across all processors
foreach ($proc in $procs)
{
    $totalCores = $totalCores + $proc.NumberOfCores
}

#get the amount of total memory (MB)
$wmi = Get-WmiObject Win32_OperatingSystem
$totalMemory = ($wmi.TotalVisibleMemorySize / 1024)

#calculate the number of files needed (= number of procs)

$tempdbFiles = $totalCores * $coreMultiplier

if ($tempdbFiles -gt $maxFileCount)
{
    $tempdbFiles = $maxFileCount
}

}

Write-Log -logfile $setupLog -level "Info" -message "TempDB Files are being set to $tempdbFiles"

function Set-TempDbSize
{
    [CmdletBinding()]
    param(

    [Parameter(Position=0, Mandatory=$false)] [switch]$outClipboard
    )

    if (!$tempdbDataSize) {

    #calculate file size (total memory / number of files)
    $tempdbDataSize = $totalMemory / $tempdbFiles
    $tempdbDataSize  = $tempdbDataSize - ($tempdbDataSize % 10)

    if ($tempdbDataSize -gt $maxFileInitialSizeMB)
    {
        $tempdbDataSize = $maxFileInitialSizeMB
    }

    }

    if (!$tempdbLogSize) {

	  $tempdbLogSize = $tempdbDataSize / 4
	  $tempdbLogSize = $tempdbLogSize - ($tempdbLogSize % 10)

    if ($tempdbLogSize -gt $maxLogFileInitialSizeMB)
    {
        $tempdbLogSize = $maxLogFileInitialSizeMB
    }

    }

    #build the sql command
    $command = @"
    declare @data_path varchar(300),
            @log_path varchar(300);

    select
        @data_path = replace([filename], 'tempdb.mdf','')
    from
        sysaltfiles s
    where
        name = 'tempdev';

    select
        @log_path = replace([filename], 'templog.ldf','')
    from
        sysaltfiles s
    where
        name = 'templog';

	declare @stmnt0 nvarchar(500)
    select @stmnt0 = N'ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N''tempdev'', FILENAME = ''' + @data_path + 'tempdata01.mdf'' , SIZE = {0}MB , MAXSIZE = UNLIMITED , FILEGROWTH = {1}% )';
    exec sp_executesql @stmnt0;
"@ -f $tempdbDataSize, $tempdbFileGrowth

		$command =  $command + @"
    declare @stmnt1 nvarchar(500)
    select @stmnt1 = N'ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N''templog'', FILENAME = ''' + @log_path + 'templog.ldf'' , SIZE = {0}MB , MAXSIZE = UNLIMITED , FILEGROWTH = {1}% )';
    exec sp_executesql @stmnt1;
"@ -f $tempdbLogSize, $tempdbFileGrowth, $i

    for ($i = 2; $i -le $tempdbFiles; $i++)
    {
        $command =  $command + @"
    declare @stmnt{2} nvarchar(500)
    select @stmnt{2} = N'ALTER DATABASE [tempdb] ADD FILE ( NAME = N''tempdev{2}'', FILENAME = ''' + @data_path + 'tempdata0{2}.mdf'' , SIZE = {0}MB , MAXSIZE = UNLIMITED , FILEGROWTH = {1}% )';
    exec sp_executesql @stmnt{2};
"@ -f $tempdbDataSize, $tempdbFileGrowth, $i
    }

    if ($outClipboard)
    {
        $command | clip
        return "The SQL query has been loaded into the clipboard."
    }
    else
    {
        return $command
    }
}

$query = Set-TempDbSize
Write-Host $query
# Invoke-SqlCmd -ServerInstance $sqlservername -Query $query -querytimeout ([int]::MaxValue)

Write-Log -logfile $setupLog -level "Info" -message "TempDB Files are currently set to $tempdbFiles"
