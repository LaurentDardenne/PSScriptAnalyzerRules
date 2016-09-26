Crée des fichiers de test à partir de cmdlet binaire à l'aide du module [MetaProgramming](https://blogs.msdn.microsoft.com/powershell/2009/01/04/extending-andor-modifing-commands-with-proxies/):
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
La création d'un proxy Powershell à l'aide de la fonction _MetaProgramming\New-ProxyCommand_ permet de tester les déclarations de paramètre d'un cmdlet binaire.
Ainsi on peut appliquer sur les scripts de proxy , les régles contenues dans le module ParameterSetRules.psm1.

Le module MetaProgramming ne semble pas fonctionner avec des ressources DSC ou des Workflow (à vérifier). 