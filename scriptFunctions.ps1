Function Write-Log
{
    param(
		[string] $logfile = $(throw "Logfile required"),
        [string] $level = $(throw "Level required"),
        [string] $message = $(throw "Message required")
    )

	$fAttention = "green"
    $fWarning = "yellow"

	$logWeb = [System.Web.HttpUtility]::HtmlEncode($message)
    $logWeb = (Get-Date).ToString() + ": $logWeb"

    switch ($level)
    {
        "Info"     	{$string = "$logWeb<br/>"}
		"Notification" {$string = "<span style='color: blue'><i>$logWeb!</i></span><br/>"}
        "Warning"  	{$string = "<span style='color: green; background-color: #ffff42'>$logWeb</span><br/>"}
        "Error"    {$string = "<span style='color: #ffffff; background-color: #ff0000'><b>$logWeb</b></span><br/>"; if ($message -ne "Sample Error") { $errorStop = $true }}
        "Header"   {$string = "<h2>$logWeb</h2>"}
        "Section"  {$string = "<h3>$logWeb</h3>"}
    }

	Write-Host $string
	$string >> $logfile

}
