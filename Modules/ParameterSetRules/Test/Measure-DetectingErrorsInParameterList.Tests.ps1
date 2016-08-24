$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{ 
  $M=Import-module "$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psd1" -Pass 
  
  $Path="$env:APPVEYOR_BUILD_FOLDER\Modules\ParameterSetRules\Test\Position"
  $CustomRulePath="$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psm1"
}
else
{ 
  $M=Import-module ..\ParameterSetRules.psd1 -Pass
  $Path=".\Position"
  $CustomRulePath="..\ParameterSetRules.psm1"  
}


$RulesMessage=&$m {$RulesMsg}

 #Todo : Copy a default xml config to disable traces on the console.

Describe "Rule DetectingErrorsInParameterList" {

    Context "When there is no violation" {

      It "Function no param() ,no cmdletbinding." {
        $FileName="$Path\Function no param() ,no cmdletbinding.ps1"
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

      It "Function with a param statement empty." {
        $FileName="$Path\Function param() empty.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath        
        $Results.Count | should be (0)
      }

      It "Function param() empty, cmdletbinding not filled." {
        $FileName="$Path\Function param() empty, cmdletbinding not filled.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

      It "Function param() empty, cmdletbinding DPS filled with 'Name1'." {
        $FileName="$Path\Function param() empty, cmdletbinding DPS filled with 'Name1'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      }      

      It "Function with 1 parameters and 1 positions (1) no ParameterSet." {
        $FileName="$Path\Function with 1 parameters and 1 positions (1) no ParameterSet.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      
      It "Function with 3 parameters and 3 positions (1,2,3) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,2,3) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

      It "Function with 3 parameters and 3 positions (1,3,2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,3,2) no ParameterSet.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

      It "Function with 3 parameters and 2 ParameterSet F2 (1,2,3) - F3 (1,2,3)." {
        $FileName="$Path\Function with 3 parameters and 2 ParameterSet F2 (1,2,3) - F3 (1,2,3).ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

      It "Function with 5 parameters and 3 ParameterSet, cmdletbinding filled." {
        $FileName="$Path\Function with 5 parameters and 3 ParameterSet, cmdletbinding filled.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
#Devrait valider la régle  4 : Les positions doivent débuter à zéro ou 1
      It "Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3)." {
        $FileName="$Path\Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3).ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
#         $Results[0].Severity| should be 'Error'
#         $Results[0].Message|should be ($RulesMessage.E_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', 'by default', '3')
     }
    }#context

#todo revoir si les noms des fichier refléte bien leur contenu
  
    Context "When there are violations" {
#régle 1 : un nom de paramètre ne doit pas commencer par un chiffre,
      It "Function with 3 parameters and 3 positions (1,7Name,2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,7Name,2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', '7Name') + $RulesMessage.E_ParameterNameInvalidByNumber)
      }

      It "Function with 3 parameters and 3 positions (1,72Name,2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,72Name,2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Warning'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', '72Name') + $RulesMessage.E_ParameterNameInvalidByNumber)
        $Results[1].Message|should be ($RulesMessage.W_PsnUnnecessaryParameterAttribut -F 'TestParameterSet', '72Name')
      }

      It "Function with 3 parameters and 3 positions (1,{Name.Com},2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,{Name.Com},2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', 'Name.Com') + $RulesMessage.E_ParameterNameInvalidByDot)
      }
      
      It "Function with 3 parameters and 3 positions (1,{+Name},2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,{+Name},2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', '+Name') + $RulesMessage.E_ParameterNameInvalidByOperator)
      }

      It "Function with 3 parameters and 3 positions (1,{Name*},2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,{Name'STAR'},2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (3)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Warning'
        $Results[2].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', 'Name*') + $RulesMessage.E_ParameterNameInvalidByPSWildcard)
        $Results[1].Message|should be ($RulesMessage.W_PsnUnnecessaryParameterAttribut -F 'TestParameterSet', 'Name*')
        $Results[2].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'by default','1,3')
      }

      It "Function with 3 parameters and 3 positions (1,{ Name},2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,{ Name},2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', ' Name') + $RulesMessage.E_ParameterNameInvalidBySpace)
      }

      It "Function with 3 parameters and 3 positions (1,{Name },2) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,{Name },2) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', 'Name ') + $RulesMessage.E_ParameterNameInvalidBySpace)
      }

# régle 2 : le nombre indiqué dans la propriété 'Position' doit être positif
      It "Function with 3 parameters and 3 positions (-1,0,1) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (-1,0,1) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'by default','A', '-1')
      }

      It "Function with 3 parameters and 3 positions (-1,-2,-3) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (-1,-2,-3) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (3)
        $Results[0].Severity| should be 'Error'                                                                          
        $Results[1].Severity| should be 'Error' 
        $Results[2].Severity| should be 'Error' 
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'by default','A', '-1')
        $Results[1].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'by default','B', '-2')
        $Results[2].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'by default','C', '-3')
      }

      It "Function with 3 parameters and 3 positions (-1,2,3) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (-1,2,3) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'by default','A', '-1')
        $Results[1].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'by default','-1,2,3')
      }   
#Régle 3 : Les positions des paramètres d'un même jeu ne doivent pas être dupliqués
       
      It "Function with 3 parameters and 3 positions (1,2,1) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,2,1) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'by default','1', 'A,C')
        $Results[1].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'by default','1,1,2')
      }

# #Régle  4 : Les positions doivent débuter à zéro ou 1
#       It "Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3)-v2." {
#         $FileName="$Path\Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3)-v2.ps1"
#         
#         $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
#         $Results.Count | should be (1)
#         $Results[0].Severity| should be 'Error'
#         $Results[0].Message|should be ($RulesMessage.E_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', 'by default', '3')
#       }

#régle 5 : L'ensemble des positions doit être une suite ordonnée d'éléments.
      It "Function with 3 parameters and 3 positions (1,2,4) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,2,4) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'by default','1,2,4')
      }

#régle 6: Un attribut [Parameter()] vide est inutile
      It "Function with ParameterAttribut() unnecessary." {
        $FileName="$Path\Function with ParameterAttribut() unnecessary.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_PsnUnnecessaryParameterAttribut -F 'TestParameterSet', 'A')
      }

#todo Function invalidate 5 rules.ps1
#todo Function with only one mandatory Parameter and ValidateAttribut.ps1

    }#context
}
