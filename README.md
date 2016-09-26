[![Build status](https://ci.appveyor.com/api/projects/status/ql5p4n4u6klxakur?svg=true)](https://ci.appveyor.com/project/LaurentDardenne/psscriptanalyzerrules)
# PSScriptAnalyzerRules
Rules for PSScriptAnalyzer   

**Documentation**

[Parameter set rules](https://github.com/LaurentDardenne/PSScriptAnalyzerRules/tree/master/Modules/ParameterSetRules/RuleDocumentation)

How to test parameterset of a [binary cmdlet](https://github.com/LaurentDardenne/PSScriptAnalyzerRules/blob/master/Modules/ParameterSetRules/en-US/Example.md).

**PowerShell 5 Installation**

From PowerShell run:
```Powershell
Register-PSRepository -Name PSScriptAnalyzerRules -SourceLocation https://ci.appveyor.com/nuget/PSScriptAnalyzerRules
Install-Module ParameterSetRules -Scope CurrentUser 
```
Or [download](https://ci.appveyor.com/project/LaurentDardenne/psscriptanalyzerrules/build/artifacts) the module.

