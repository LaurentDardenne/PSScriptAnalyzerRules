Param (
 # Specific to the development computer
 [string] $VcsPathRepository=''
) 

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{
  $VcsPathRepository=$env:APPVEYOR_BUILD_FOLDER
}

if (!(Test-Path $VcsPathRepository))
{
  Throw 'Configuration error, the variable $VcsPathRepository should be configured.'
}

#Variable commune à tous les postes
#todo ${env:Name with space}
if ( $null -eq [System.Environment]::GetEnvironmentVariable("ProfilePSScriptAnalyzerRules","User"))
{ 
 [Environment]::SetEnvironmentVariable("ProfilePSScriptAnalyzerRules",$VcsPathRepository, "User")
  #refresh the environment Provider
 $env:ProfilePSScriptAnalyzerRules=$VcsPathRepository 
}

 # Variable spécifiques au poste de développement
$PSScriptAnalyzerRulesDelivry= "${env:temp}\Delivry\PSScriptAnalyzerRules"   
$PSScriptAnalyzerRulesLogs= "${env:temp}\Logs\PSScriptAnalyzerRules" 

 # Variable communes à tous les postes, leurs contenu est spécifique au poste de développement
$PSScriptAnalyzerRulesBin= "$VcsPathRepository\Bin"
$PSScriptAnalyzerRulesHelp= "$VcsPathRepository\Documentation\Helps"
$PSScriptAnalyzerRulesSetup= "$VcsPathRepository\Setup"
$PSScriptAnalyzerRulesVcs= "$VcsPathRepository"
$PSScriptAnalyzerRulesTests= "$VcsPathRepository\Tests"
$PSScriptAnalyzerRulesTools= "$VcsPathRepository\Tools"
$PSScriptAnalyzerRulesUrl= 'https://github.com/LaurentDardenne/PSScriptAnalyzerRules.git'

 #PSDrive sur le répertoire du projet 
$null=New-PsDrive -Scope Global -Name PSScriptAnalyzerRules -PSProvider FileSystem -Root $PSScriptAnalyzerRulesVcs 

Write-Host "Settings of the variables of PSScriptAnalyzerRules project." -Fore Green

rv VcsPathRepository

