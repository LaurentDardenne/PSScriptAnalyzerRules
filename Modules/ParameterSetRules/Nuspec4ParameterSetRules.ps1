if(! (Test-Path variable:PSScriptAnalyzerRulesVcs))
{ throw "The project configuration is required, see the 'PSScriptAnalyzerRules_ProjectProfile.ps1' script." }

$ModuleVersion=(Import-ManifestData "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psd1").ModuleVersion

$Result=nuspec 'ParameterSetRules' $ModuleVersion {
   properties @{
        Authors='Dardenne Laurent'
        Owners='Dardenne Laurent'
        Description='PSScriptAnalyzer rules to validate the param block of a function.'
        title='ParameterSetRules module'
        summary='PSScriptAnalyzer rules to validate the param block of a function.'
        copyright='Copyleft'
        language='fr-FR'
        licenseUrl='https://creativecommons.org/licenses/by-nc-sa/4.0/'
        projectUrl='https://github.com/LaurentDardenne/PSScriptAnalyzerRules'
        #iconUrl='https://github.com/LaurentDardenne/ParameterSetRules/blob/master/icon/ParameterSetRules.png'
#todo
        releaseNotes="$(Get-Content "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\CHANGELOG.md" -raw)" 
        tags='Powershell PSScriptAnalyzer Rule param ParameterSet'
   }
   
   dependencies {
        dependency PSScriptAnalyzer 1.7.0
   }     
   
   files {
        file -src "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psd1"
        file -src "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psm1"
        file -src "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\RuleDocumentation" -target "RuleDocumentation\"
        #file -src "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\README.md"
        #file -src "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\releasenotes.md"
   }        
}

$Result|
  Push-nupkg -Path $PSScriptAnalyzerRulesDelivery -Source 'https://www.myget.org/F/ottomatt/api/v2/package'
  
