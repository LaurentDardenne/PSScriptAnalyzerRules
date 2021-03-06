﻿ param(        
		[string]$BuildNumber,
		[string]$InstallDir,
		[string]$LogUrl,
        [string]$ResolvedDeviceType = "Default"
        )
# Always Stop on Error
$ErrorActionPreference = "Stop"

function LogStatus
([string] $Message)
{
    try 
    {
	    $statusUrl = $LogUrl + "status"
	    Invoke-RestMethod -Method Post -Uri $statusUrl -ContentType "application/json" -Body (@{ClientName=$env:computername;message=$Message} | ConvertTo-JSON)
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Add-Content $OutFile "An error $ErrorMessage occured logging the status message $Message"
    }
}

function LogError
([string] $Message)
{
    try {
	    $errorUrl = $LogUrl + "error"
	    Invoke-RestMethod -Method Post -Uri $errorUrl -ContentType "application/json" -Body (@{ClientName=$env:computername;message=$Message} | ConvertTo-JSON)
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Add-Content $OutFile "An error $ErrorMessage occured logging the error message $Message"
    }
}

LogStatus "Applying ClientConfiguration"

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Script is not running as administrator.`nPlease re-run this script as an Administrator!"
	LogStatus "Cannot apply ClientConfiguration. Script is not running as admin."
    Break
}

try 
{
    $ScriptFolder = $PSScriptRoot
    LogStatus "Configuration beginning. Checking and writing upgrade attempt count";
	
	$AttemptCountFile = Join-Path $InstallDir "attempt.txt"
	
	if (Test-Path $AttemptCountFile) {
        $AttemptCount = 0
        $Content = (Get-Content -Path $AttemptCountFile)
        if ([int]::TryParse($Content, [ref]$AttemptCount)){            
            $AttemptCount++        
        } 
        else {         
            $AttemptCount = 0
        }				
	}
	else {
		$AttemptCount = 1;
	}
	
	if ($AttemptCount -gt 5) {
        LogError "Too many upgrade attempts on this device so not retrying."
        break;
    }

	Set-Content $AttemptCountFile $AttemptCount
    
	LogStatus "Updating upgrade attempt count. Attempt count $AttemptCount";
}
catch {
	$ErrorMessage = $_.Exception.Message
	LogError "An error '$ErrorMessage' occured during checking and writing upgrade attempt count";
	break
}
# Create a function to display the current settings of the Unified Write Filter driver.
function TestUWFEnabled() 
{    
	#$COMPUTER = "localhost"
	$NAMESPACE = "root\standardcimv2\embedded"
	# Check for the existance of the UWF_Filter
    $uwfInstance = Get-WmiObject -Namespace $NAMESPACE -Class UWF_Filter -List;
	
    if(!$uwfInstance) {
        return $false;
    }
    # Get the instance of the Filter
	$uwfInstance = Get-WmiObject -Namespace $NAMESPACE -Class UWF_Filter;

    # Check the CurrentEnabled property to see if UWF is enabled in the current session.
    if($uwfInstance.CurrentEnabled) {
		LogStatus "UWF is currently enabled"
        return $true
    } 

    # Check the NextEnabled property to see if UWF is enabled or disabled after the next system restart.
    if($uwfInstance.NextEnabled) {
	LogStatus "UWF is set to be Enabled on next boot"
        return $true
    } 

    # Check the HORMEnabled property to see if Hibernate Once/Resume Many (HORM) is enabled for the current session.
    if($uwfInstance.HORMEnabled) {
	LogStatus "UWF is HORM Enabled"
        return $true
    } 
	LogStatus "UWF is present but not currently enabled."
	return $false  
}

$UWFEnabled = TestUWFEnabled