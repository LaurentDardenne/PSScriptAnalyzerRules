Create files test from binary cmdlets using the module [MetaProgramming](https://blogs.msdn.microsoft.com/powershell/2009/01/04/extending-andor-modifing-commands-with-proxies/) :
```Powershell
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
The creation of a proxy Powershell using the _MetaProgramming \ New ProxyCommand_ function allow to test the parameter statements  of a binary cmdlet.
Thus we can apply on proxy scripts, rules contained in ParameterSetRules.psm1 module.

The Module Metaprogramming the unit is not working with DSC resources or Workflow (to check).
 