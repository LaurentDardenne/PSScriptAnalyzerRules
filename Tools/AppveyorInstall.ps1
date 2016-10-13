 #nouvelle session pour installer PowershellGet
PowerShell.exe -Command {
  Install-PackageProvider Nuget -ForceBootstrap -Force
  Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  Install-module PowershellGet -MinimumVersion 1.1.0.0 -Force -Scope AllUsers 
}

 #On utilise la dernière version installé
Install-Module -Name 'PSScriptAnalyzer' -Repository PSGallery -Scope AllUsers -Force -SkipPublisherCheck

Install-Module Psake -force
Import-Module Psake

 #Install/Update required modules
. "$PSScriptAnalyzerRulesVcs\Tools\Install.ps1"