#Dependencies.ps1
#Install or update the dependencies (Modules,scripts, binaries)
 [CmdletBinding(DefaultParameterSetName = "Install")]
 Param(
     [Parameter(ParameterSetName="Update")]
   [switch] $Update
 )
#Par défaut on installe, sinon on met à jour
#Et on force l'installe pour le CI  
if (Test-Path env:APPVEYOR)
{ Invoke-Psake .\Dependencies.ps1 -parameters @{"Mode"="Install"} -nologo }
else
{ Invoke-Psake .\Dependencies.ps1 -parameters @{"Mode"="$($PsCmdlet.ParameterSetName)"} -nologo }

