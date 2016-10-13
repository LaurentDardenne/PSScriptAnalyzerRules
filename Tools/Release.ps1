#Release.ps1
#Construit la version Release via Psake

Task default -Depends Nuget

Task NuGet -Depends CreateZip,PublishOnMyGet  {
 #Register-PSRepository -Name PSScriptAnalyzerRules -SourceLocation https://ci.appveyor.com/nuget/PSScriptAnalyzerRules
 #Install-Module ParameterSetRules -Scope CurrentUser 
  $PathNuget="$env:Temp\nuget"
  if (! (Test-Path  $PathNuget) )
  { md $PathNuget }

  $ImportManifestData={ 
      Param (
          [Parameter(Mandatory = $true)]
          [Microsoft.PowerShell.DesiredStateConfiguration.ArgumentToConfigurationDataTransformation()]
          [hashtable] $data
      )
      return $data
  }
  $Manifest=&$ImportManifestData "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psd1"

  #Gestion manuelle du numéro de version dans le manifest de module
  # nuget v3.4.4.1321 code le numéro de version '0.2.0.0' en '0.2.0'
  Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.nuspec" "$PSScriptAnalyzerRulesDelivery"
  Write-Host 'Création du package nuget'
  nuget pack "$PSScriptAnalyzerRulesDelivery\ParameterSetRules.nuspec" -outputdirectory  $PathNuget 

  Write-Host "Création de l'artifact du package nuget."
  if (Test-Path env:APPVEYOR)
  { Push-AppveyorArtifact "$PathNuget\ParameterSetRules.$($Manifest.ModuleVersion).nupkg" } 
}

Task PublishOnMyGet -Precondition { Test-Path env:APPVEYOR } {
 
 $PublishParams = @{
    Repository='OttoMatt'
    NuGetApiKey = $MyGetApiKey
    Path = $PSScriptAnalyzerRulesDelivery
    ReleaseNotes=Get-Content "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\CHANGELOG.md" -raw
 }
 Publish-Module @PublishParams
}

Task CreateZip -Depends Delivery,TestBomFinal,Analyze {

  $zipFile = "$env:Temp\PSScriptAnalyzerRules.zip"
  if (Test-Path $zipFile)
  { Remove-item $zipFile } 
  Add-Type -assemblyname System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($PSScriptAnalyzerRulesDelivery, $zipFile)

  if (Test-Path env:APPVEYOR)
  {  Push-AppveyorArtifact $zipFile }
}

Task Delivery -Depends Clean,RemoveConditionnal {
 #Recopie les fichiers dans le répertoire de livraison  
$VerbosePreference='Continue'
 
#log4Net config
# on copie la config de dev nécessaire au build.
   if ($Configuration -eq "Debug") 
   { Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRulesLog4Posh.Config.xml" "$PSScriptAnalyzerRulesDelivery" }

#Doc xml localisée
   #US
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.Resources.psd1" "$PSScriptAnalyzerRulesDelivery\ParameterSetRules.Resources.psd1" 
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\en-US\about_ParameterSetRules.help.txt" "$PSScriptAnalyzerRulesDelivery\en-US\about_ParameterSetRules.help.txt"
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\en-US\Example.md"  "$PSScriptAnalyzerRulesDelivery\en-US\Example.md"


  #Fr 
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\fr-FR\ParameterSetRules.Resources.psd1" "$PSScriptAnalyzerRulesDelivery\fr-FR\ParameterSetRules.Resources.psd1"
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\fr-FR\about_ParameterSetRules.help.txt" "$PSScriptAnalyzerRulesDelivery\fr-FR\about_ParameterSetRules.help.txt"
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\fr-FR\Example.md"  "$PSScriptAnalyzerRulesDelivery\fr-FR\Example.md"
 
#Module
      #ParameterSetRules.psm1 et ParameterSetRules.psd1 sont créés par la tâche RemoveConditionnal
   
#Other 
   Copy "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\CHANGELOG.md" "$PSScriptAnalyzerRulesDelivery"
} #Delivery

Task RemoveConditionnal {
#Traite les pseudo directives de parsing conditionnelle
  
   $VerbosePreference='Continue'
   ."${env:ProgramFiles}\WindowsPowerShell\Scripts\Remove-Conditionnal.ps1"
   Write-debug "Configuration=$Configuration"
   Write-Warning "Traite la configuration $Configuration"
   Dir "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psm1",
       "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\ParameterSetRules.psd1"|
    Foreach {
      $Source=$_
      Write-Verbose "Parse :$($_.FullName)"
      $CurrentFileName="$PSScriptAnalyzerRulesDelivery\$($_.Name)"
      Write-Warning "CurrentFileName=$CurrentFileName"
      if ($Configuration -eq "Release")
      { 
         #Supprime les lignes de code de Debug et de test
         #On traite une directive et supprime les lignes demandées. 
         #On inclut les fichiers.       
        Get-Content -Path $_ -ReadCount 0 -Encoding UTF8|
         Remove-Conditionnal -ConditionnalsKeyWord 'DEBUG' -Include -Remove -Container $Source|
         Remove-Conditionnal -Clean| 
         Set-Content -Path $CurrentFileName -Force -Encoding UTF8        
      }
      else
      { 
         #On ne traite aucune directive et on ne supprime rien. 
         #On inclut uniquement les fichiers.

         #Directive inexistante et on ne supprime pas les directives
         #sinon cela génére trop de différences en cas de comparaison de fichier
        Get-Content -Path $_ -ReadCount 0 -Encoding UTF8|
         Remove-Conditionnal -ConditionnalsKeyWord 'NODEBUG' -Include -Container $Source|
         Set-Content -Path $CurrentFileName -Force -Encoding UTF8       
      }
    }#foreach
} #RemoveConditionnal

  

Task Clean -Depends Init {
# Supprime, puis recrée le dossier de livraison   

   $VerbosePreference='Continue'
   Remove-Item $PSScriptAnalyzerRulesDelivery -Recurse -Force -ea SilentlyContinue
   
   $Directories=@(
     "$PSScriptAnalyzerRulesDelivery\en-US", 
     "$PSScriptAnalyzerRulesDelivery\fr-FR"
   )
   if ($Configuration -eq "Debug") 
   { $Directories +="$PSScriptAnalyzerRulesDelivery\Logs" }
   
   $Directories|
   Foreach {
    md $_ -Verbose -ea SilentlyContinue > $null
   } 
} #Clean

Task Init -Depends TestBOM, Dependencies {
#validation à minima des prérequis
 Write-host "Mode $Configuration"
} #Init

Task TestBOM {
#Validation de l'encodage des fichiers AVANT la génération  
#La régle 'UseBOMForUnicodeEncodedFile' de PSScripAnalyzer s'assure 
#que les fichiers qui ne sont pas encodé ASCII ont un BOM.
#Comme ici on ne veut que des fichiers UTF-8, cette régle est trop 'permissive'.

  Write-Host "Validation de l'encodage des fichiers du répertoire : $PSScriptAnalyzerRulesVcs"
  
  Import-Module DTW.PS.FileSystem -Global
  
  $InvalidFiles=@(&"${env:ProgramFiles}\WindowsPowerShell\Scripts\Test-BOMFile.ps1" $PSScriptAnalyzerRulesVcs)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOM


Task Dependencies {
#Install ou met à jour les prérequis
#Appveyor utilisera tjr la dernière version

#Suppose PowershellGet à jour :  Update-module PowershellGet -Force 

'Pester','PsScriptAnalyzer' |
 Foreach { 
    $ModuleName=$_
    try {
      Write-host "Update $ModuleName"
      Update-module -name $ModuleName -Force
    }
    catch [Microsoft.PowerShell.Commands.WriteErrorException]{
      if ($_.FullyQualifiedErrorId -match ('^ModuleNotInstalledOnThisMachine'))
      {
        Write-host "Install $ModuleName"
           #On précise le repository car Pester est également sur Nuget 
        Install-Module -Name $ModuleName -Repository PSGallery -Scope AllUsers -SkipPublisherCheck 
      }
      else 
      { throw $_ }
    }
 }
}#Dependencies

#On duplique la tâche, car PSake ne peut exécuter deux fois une même tâche
Task TestBOMFinal {

#Validation de l'encodage des fichiers APRES la génération  
  
  Write-Host "Validation de l'encodage des fichiers du répertoire : $PSScriptAnalyzerRulesDelivery"
  $InvalidFiles=@(&"${env:ProgramFiles}\WindowsPowerShell\Scripts\Test-BOMFile.ps1" $PSScriptAnalyzerRulesDelivery)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOMFinal

Task Analyze -Depend Pester,TestLocalizedData {

}#Analyze


Task TestLocalizedData -ContinueOnError {
Write-warning "Todo TestLocalizedData"
#  ."$PsIonicTools\Test-LocalizedData.ps1"
# Show-BalloonTip –Text $TaskName –Title 'Build Psionic' –Icon Info

#  $SearchDir="$PsionicTrunk"
#  Foreach ($Culture in $Cultures)
#  {
#    Dir "$SearchDir\Psionic.psm1"|          
#     Foreach-Object {
#        #Construit un objet contenant des membres identiques au nombre de 
#        #paramètres de la fonction Test-LocalizedData 
#       New-Object PsCustomObject -Property @{
#                                      Culture=$Culture;
#                                      Path="$SearchDir";
#                                        #convention de nommage de fichier d'aide
#                                      LocalizedFilename="$($_.BaseName)LocalizedData.psd1";
#                                      FileName=$_.Name;
#                                        #convention de nommage de variable
#                                      PrefixPattern="$($_.BaseName)Msgs\."
#                                   }
#     }|   
#     Test-LocalizedData -verbose
#  }
} #TestLocalizedData     
     
Task Pester -Precondition { -not (Test-Path env:APPVEYOR)} -Depends PSScriptAnalyzer {
   #Execute les tests via la config de Appveyor, ansi on renseigne l'onglet Test :
   # https://ci.appveyor.com/project/LaurentDardenne/psscriptanalyzerrules/build/tests
  if (Test-Path env:APPVEYOR)
  {  return }        
  
  cd  "$PSScriptAnalyzerRulesVcs\Modules\ParameterSetRules\Test"
  $ResultsFile="$env:Temp\PSScriptAnalyzerRulesPester.xml"
  $Results = Invoke-Pester  -OutputFormat NUnitXml -OutputFile $ResultsFile -PassThru
  C:\Dev\Reportunit\ReportUnit.exe "$env:Temp\PSScriptAnalyzerRulesPester.xml" C:\temp\report.html
  
  if ($Results.FailedCount -gt 0) { 
      throw "Pester : $($Results.FailedCount) tests ont échoués."
  }   
}#Pester

Task PSScriptAnalyzer -Precondition { -not (Test-Path env:APPVEYOR) } {
  Write-Host "Analyse du code des scripts"
  Import-Module PsScriptAnalyzer
  $Params=@{
    Path="$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psm1"
    CustomRulePath="$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psm1" 
    #Severity='Error'
    #ErrorAction='SilentlyContinue'
  }
  $Results = Invoke-ScriptAnalyzer @Params -IncludeDefaultRules
  If ($Results) {
    $ResultString = $Results | Out-String
    Write-host 'PSScriptAnalyzer renvoit des erreurs'
    Write-Warning $ResultString
    Throw "Invoke-ScriptAnalyzer failed"
  }
  Else 
  { Write-host 'PsScriptAnalyzer réussite de l''analyse' -fore green }
}#PSScriptAnalyzer
