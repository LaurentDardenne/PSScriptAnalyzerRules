#Release.ps1
#Construit la version Release via Psake

Task default -Depends CreateZip 

Task CreateZip -Depends Delivery,ValideParameterSet,TestBomFinal {

  $zipFile = "$env:\Temp\PSScriptAnalyzerRules.zip"
  Add-Type -assemblyname System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($PSScriptAnalyzerRulesDelivry, $zipFile)
  if (Test-Path env:APPVEYOR)
  { Push-AppveyorArtifact $zipFile }     
}

Task Delivery -Depends Clean,RemoveConditionnal {
 #Recopie les fichiers dans le répertoire de livraison  
$VerbosePreference='Continue'
 
#log4Net config
# on copie la config de dev nécessaire au build. 
   Copy "$PSScriptAnalyzerRulesVcs\Log4Net.Config.xml" "$PSScriptAnalyzerRulesLivraison"

#Doc xml localisée
   #US
   Copy "$PSScriptAnalyzerRulesVcs\en-US\PSScriptAnalyzerRules.Resources.psd1" "$PSScriptAnalyzerRulesLivraison\en-US\PSScriptAnalyzerRules.Resources.psd1" 
   Copy "$PSScriptAnalyzerRulesVcs\en-US\about_PSScriptAnalyzerRules.help.txt" "$PSScriptAnalyzerRulesLivraison\en-US\about_PSScriptAnalyzerRules.help.txt"

  #Fr 
   Copy "$PSScriptAnalyzerRulesVcs\fr-FR\${PLASTER_PARAM_ProjectName}.Resources.psd1" "$PSScriptAnalyzerRulesLivraison\fr-FR\PSScriptAnalyzerRules.Resources.psd1"
   Copy "$PSScriptAnalyzerRulesVcs\fr-FR\about_PSScriptAnalyzerRules.help.txt" "$PSScriptAnalyzerRulesLivraison\fr-FR\about_PSScriptAnalyzerRules.help.txt"
 

#Demos
   Copy "$PSScriptAnalyzerRulesVcs\Demos" "$PSScriptAnalyzerRulesLivraison\Demos" -Recurse

#PS1xml   

#Licence                         

#Module
      #$PSScriptAnalyzerRules.psm1 est créé par la tâche RemoveConditionnal
   Copy "$PSScriptAnalyzerRulesVcs\PSScriptAnalyzerRules.psd1" "$PSScriptAnalyzerRulesLivraison"
   
#Setup
   Copy "$PSScriptAnalyzerRulesSetup\PSScriptAnalyzerRulesSetup.ps1" "$PSScriptAnalyzerRulesLivraison"

#Other 
   Copy "$PSScriptAnalyzerRulesVcs\Revisions.txt" "$PSScriptAnalyzerRulesLivraison"
} #Delivery

Task RemoveConditionnal -Depend TestLocalizedData {
#Traite les pseudo directives de parsing conditionnelle
  
   $VerbosePreference='Continue'
   ."$PSScriptAnalyzerRulesTools\Remove-Conditionnal.ps1"
   Write-debug "Configuration=$Configuration"
   Dir "$PSScriptAnalyzerRulesVcs\PSScriptAnalyzerRules.psm1"|
    Foreach {
      $Source=$_
      Write-Verbose "Parse :$($_.FullName)"
      $CurrentFileName="$PSScriptAnalyzerRulesLivraison\$($_.Name)"
      Write-Warning "CurrentFileName=$CurrentFileName"
      if ($Configuration -eq "Release")
      { 
         Write-Warning "`tTraite la configuration Release"
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
        Write-Warning "`tTraite la configuration DEBUG" 
         #Directive inexistante et on ne supprime pas les directives
         #sinon cela génére trop de différences en cas de comparaison de fichier
        Get-Content -Path $_ -ReadCount 0 -Encoding UTF8|
         Remove-Conditionnal -ConditionnalsKeyWord 'NODEBUG' -Include -Container $Source|
         Set-Content -Path $CurrentFileName -Force -Encoding UTF8       
         
      }
    }#foreach
} #RemoveConditionnal

Task TestLocalizedData -ContinueOnError {
 ."$PSScriptAnalyzerRulesTools\Test-LocalizedData.ps1"

 $SearchDir="$PSScriptAnalyzerRulesVcs"
 Foreach ($Culture in $Cultures)
 {
   Dir "$SearchDir\PSScriptAnalyzerRules.psm1"|          
    Foreach-Object {
       #Construit un objet contenant des membres identiques au nombre de 
       #paramètres de la fonction Test-LocalizedData 
      New-Object PsCustomObject -Property @{
                                     Culture=$Culture;
                                     Path="$SearchDir";
                                       #convention de nommage de fichier d'aide
                                     LocalizedFilename="$($_.BaseName)LocalizedData.psd1";
                                     FileName=$_.Name;
                                       #convention de nommage de variable
                                     PrefixPattern="$($_.BaseName)Msgs\."
                                  }
    }|   
    Test-LocalizedData -verbose
 }
} #TestLocalizedData

Task Clean -Depends Init {
# Supprime, puis recrée le dossier de livraison   

   $VerbosePreference='Continue'
   Remove-Item $PSScriptAnalyzerRulesLivraison -Recurse -Force -ea SilentlyContinue
   "$PSScriptAnalyzerRulesLivraison\en-US", 
   "$PSScriptAnalyzerRulesLivraison\fr-FR", 
   "$PSScriptAnalyzerRulesLivraison\FormatData",
   "$PSScriptAnalyzerRulesLivraison\TypeData",
   "$PSScriptAnalyzerRulesLivraison\Logs"|
   Foreach {
    md $_ -Verbose -ea SilentlyContinue > $null
   } 
} #Clean

Task Init -Depends TestBOM {
#validation à minima des prérequis

 Write-host "Mode $Configuration"
  if (-not (Test-Path Env:ProfilePSScriptAnalyzerRules))
  {Throw 'La variable $ProfilePSScriptAnalyzerRules n''est pas déclarée.'}
    
} #Init

Task TestBOM {
#Validation de l'encodage des fichiers AVANT la génération  
  Write-Host "Validation de l'encodage des fichiers du répertoire : $PSScriptAnalyzerRulesVcs"
  
  Import-Module DTW.PS.FileSystem -Global
  
  $InvalidFiles=@(&"$PSScriptAnalyzerRulesTools\Test-BOMFile.ps1" $PSScriptAnalyzerRulesVcs)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOM

#On duplique la tâche, car PSake ne peut exécuter deux fois une même tâche
Task TestBOMFinal {

#Validation de l'encodage des fichiers APRES la génération  
  
  Write-Host "Validation de l'encodage des fichiers du répertoire : $PSScriptAnalyzerRulesLivraison"
  $InvalidFiles=@(&"$PSScriptAnalyzerRulesTools\Test-BOMFile.ps1" $PSScriptAnalyzerRulesLivraison)
  if ($InvalidFiles.Count -ne 0)
  { 
     $InvalidFiles |Format-List *
     Throw "Des fichiers ne sont pas encodés en UTF8 ou sont codés BigEndian."
  }
} #TestBOMFinal

Task ValideParameterSet {
  # requiert PS V3 pour la vérification

  ."$PSScriptAnalyzerRulesTools\New-FileNameTimeStamped.ps1"
  ."$PSScriptAnalyzerRulesTools\Test-DefaultParameterSetName.ps1"
  ."$PSScriptAnalyzerRulesTools\Test-ParameterSet.ps1"
  Import-Module "$PSScriptAnalyzerRulesLivraison\PSScriptAnalyzerRules.psd1" -global
  $Module=Import-Module "$PSScriptAnalyzerRulesLivraison\PSScriptAnalyzerRules.psd1" -PassThru
  $WrongParameterSet= @(
    $Module.ExportedFunctions.GetEnumerator()|
     Foreach-Object {
       Test-DefaultParameterSetName -Command $_.Key |
       Where-Object {-not $_.isValid} |
       Foreach-Object { 
         Write-Warning "[$($_.CommandName)]: Le nom du jeu par défaut $($_.Report.DefaultParameterSetName) est invalide."
         $_
       }
      
       Get-Command $_.Key |
        Test-ParameterSet |
        Where-Object {-not $_.isValid} |
        Foreach-Object { 
          Write-Warning "[$($_.CommandName)]: Le jeu $($_.ParameterSetName) est invalide."
          $_
        }
     }
  )
  if ($WrongParameterSet.Count -gt 0) 
  {
    $FileName=New-FileNameTimeStamped "$PSScriptAnalyzerRulesLogs\WrongParameterSet.ps1"
    $WrongParameterSet |Export-CliXml $FileName
    throw "Des fonctions déclarent des jeux de paramétres erronés. Voir les détails dans le fichier :`r`n $Filename"
  }
}#ValideParameterSet

