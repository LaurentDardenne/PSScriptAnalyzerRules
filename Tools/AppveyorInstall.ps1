 #nouvelle session pour installer PowershellGet
PowerShell.exe -Command {
  Install-PackageProvider Nuget -ForceBootstrap -Force > $null
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  Install-module PowershellGet -MinimumVersion 1.1.0.0 -Force -Scope AllUsers 
} 

Install-Module Psake -force
Import-Module Psake

 #Install/Update required modules
. "$PSScriptAnalyzerRulesVcs\Tools\Install.ps1"