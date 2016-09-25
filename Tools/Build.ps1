#Build.ps1
#Construit la version de PSScriptAnalyzerRules  
 [CmdletBinding(DefaultParameterSetName = "Debug")]
 Param(
     [Parameter(ParameterSetName="Release")]
   [switch] $Release
 ) 
# Le profile du projet (PSScriptAnalyzerRules_ProjectProfile.ps1) doit être chargé
if (-not (Test-Path Env:ProfilePSScriptAnalyzerRules))
{ Throw 'La variable d''environnement $ProfilePSScriptAnalyzerRules n''est pas déclarée.' }
Set-Location $PSScriptAnalyzerRulesTools

Import-Module Psake -EA stop -force

$Error.Clear()
if (Test-Path env:APPVEYOR)
{ Invoke-Psake .\Release.ps1 -parameters @{"Configuration"="Release"} -nologo }
else
{ Invoke-Psake .\Release.ps1 -parameters @{"Configuration"="$($PsCmdlet.ParameterSetName)"} -nologo }


