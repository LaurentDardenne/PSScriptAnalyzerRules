**Documentation**

[Parameter set rules](https://github.com/LaurentDardenne/PSScriptAnalyzerRules/tree/master/Modules/ParameterSetRules/RuleDocumentation)

How to test parameterset of a [binary cmdlet](https://github.com/LaurentDardenne/PSScriptAnalyzerRules/blob/master/Modules/ParameterSetRules/en-US/Example.md).


**PowerShell 5 Installation, (development version)**

From PowerShell run:
```Powershell
$PSGalleryPublishUri = 'https://www.myget.org/F/ottomatt/api/v2/package'
$PSGallerySourceUri = 'https://www.myget.org/F/ottomatt/api/v2'

Register-PSRepository -Name OttoMatt -SourceLocation $PSGallerySourceUri -PublishLocation $PSGalleryPublishUri #-InstallationPolicy Trusted

Install-Module ParameterSetRules -Repository OttoMatt -Verbose -Force
```

