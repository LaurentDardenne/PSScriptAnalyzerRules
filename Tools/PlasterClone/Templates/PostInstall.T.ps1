#PostInstallClone 
#Project PSScriptAnalyzerRules   

$Delivery="$('<%=${PLASTER_PARAM_Delivery}%>'.TrimEnd('\','/'))\PSScriptAnalyzerRules"   
$Logs="$('<%=${PLASTER_PARAM_Logs}%>'.TrimEnd('\','/'))\PSScriptAnalyzerRules"
$Delivery,$logs|
 Foreach { 
   if (!(Test-Path $_)
   ( New-Item $_ -ItemType Directory > $null }
 }  

 #Library for Explorer
Copy-item '<%=${PLASTER_DestinationPath}%>\PSScriptAnalyzerRules.library-ms' '<%=${Env:AppData}%>\Microsoft\Windows\Libraries\PSScriptAnalyzerRules.library-ms' -Force

#Project profile 
if (!(Test-Path "$PSProfile\ProjectsProfile")
 ( New-Item "$PSProfile\ProjectsProfile" -ItemType Directory > $null}   
Copy-item '<%=${PLASTER_DestinationPath}%>\PSScriptAnalyzerRules_ProjectProfile.ps1' "$PSProfile\ProjectsProfile" -Force


