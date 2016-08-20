
# Spécifique au poste de développement
$VcsPathRepository="<%=${PLASTER_DestinationPath}%>" 

#Variable commune à tous les postes
#todo ${env:Name with space}
if ( $null -eq [System.Environment]::GetEnvironmentVariable("ProfilePSScriptAnalyzerRules","User"))
{ [Environment]::SetEnvironmentVariable("ProfilePSScriptAnalyzerRules",$VcsPathRepository, "User") }

 # Variable spécifiques au poste de développement
$PSScriptAnalyzerRulesDelivery= "$('<%=${PLASTER_PARAM_Delivery}%>'.TrimEnd('\','/'))\PSScriptAnalyzerRules"   
$PSScriptAnalyzerRulesLogs= "$('<%=${PLASTER_PARAM_Logs}%>'.TrimEnd('\','/'))\PSScriptAnalyzerRules" 

 # Variable communes à tous les postes, leurs contenu est spécifique au poste de développement
$PSScriptAnalyzerRulesBin= "$VcsPathRepository\Bin"
$PSScriptAnalyzerRulesHelp= "$VcsPathRepository\Documentation\Helps"
$PSScriptAnalyzerRulesSetup= "$VcsPathRepository\Setup"
$PSScriptAnalyzerRulesVcs= "$VcsPathRepository"
$PSScriptAnalyzerRulesTests= "$VcsPathRepository\Tests"
$PSScriptAnalyzerRulesTools= "$VcsPathRepository\Tools"
$PSScriptAnalyzerRulesUrl= 'todo'
#todo a supprimer une fois l'url du projet renseigné
Set-PSBreakpoint -Variable PSScriptAnalyzerRulesUrl -Mode readwrite 

 #PSDrive sur le répertoire du projet 
$null=New-PsDrive -Scope Global -Name PSScriptAnalyzerRules -PSProvider FileSystem -Root $PSScriptAnalyzerRulesVcs 

Write-Host "Projet PSScriptAnalyzerRules configuré." -Fore Green

rv VcsPathRepository


