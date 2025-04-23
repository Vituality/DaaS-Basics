#
# BWILogging.psm1
#

New-Variable -Name Logging      -Value ([hashtable]::Synchronized(@{})) -Option ReadOnly

Function Set-LoggingParameters
{
	[CmdletBinding()] 
	param(
		[Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
		$ScriptName,
		[Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
		$Path,
        [ValidateNotNullOrEmpty()]
        [ValidateSet('FULL','ERROR')]
        [string]$LogLevel = 'ERROR'
    ) 
	

	if(!(Test-Path -Path $Path )){
		New-Item -ItemType directory -Path $Path | out-null
	}

	$fullPath = $Path+$ScriptName+".log"

	$Logging.ScriptName = $ScriptName
	$Logging.Path = $fullPath
	$Logging.ID = Get-Random -Minimum 0 -Maximum 1000
	$Logging.Level = $LogLevel
}

Function Write-Log {
     [CmdletBinding()]
     param(
		 [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [string]$Function,

         [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [string]$Message,
 
         [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('INFO','WARN','ERROR')]
         [string]$Severity = 'INFO'
	)
	
	if($Logging.Level -eq "ERROR" -and ($Severity -eq "INFO" -or $Severity -eq "WARN"))
	{
		return
	}

	$time = Get-Date -f "yyyy-MM-dd HH:mm:ss.ffff"
	$id = $Logging.ID
	$scriptname = $Logging.ScriptName
	$value = "$time $id [$scriptname] $Severity [$Function] $Message."

	try
	{
		Add-Content -Path $Logging.Path -Value $value
	}
	catch
	{
	}
	
}