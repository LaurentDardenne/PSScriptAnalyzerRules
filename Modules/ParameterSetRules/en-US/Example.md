Create files test from binary cmdlets :
```Powershell
 #https://blogs.msdn.microsoft.com/powershell/2009/01/04/extending-andor-modifing-commands-with-proxies/
Import-Module MetaProgramming

$cmdNames=@(
  'Where-Object',
  'Invoke-Command',
  'Enter-PSSession',
  'Receive-PSSession',
  'Import-Module',
  'Split-Path',
  'Get-Process',
  'Invoke-WmiMethod',
  'Get-PSBreakpoint',
  'Set-Clipboard',
  'Convert-Xml'
)

foreach ($cmd in $cmdNames) # or in (Get-Command -Module MyBinaryModule)) 
{
   try {
     $Name=$cmd
     Write-host "Create $env:Temp\${Name}Test.ps1" 
     $C=New-ProxyCommand -name $Name
@"
Function ${Name}Test {
$C
}
"@ |set-content "$env:Temp\${Name}Test.ps1" -encoding utf8
 }
 catch 
 { write-error $_ }
}
```