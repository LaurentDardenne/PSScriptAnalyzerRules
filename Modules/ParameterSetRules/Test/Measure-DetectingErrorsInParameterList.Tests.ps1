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


$RulesMessage,$SharedParameterSetName=&$m {$RulesMsg,$script:SharedParameterSetName}

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

      It "Function with only one mandatory Parameter and ValidateAttribut." {
        $FileName="$Path\Function with only one mandatory Parameter and ValidateAttribut.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

#Tests de non regression
      It "Proxy Add-AccessControlEntryTest." {
        $FileName="$Path\Proxy\Add-AccessControlEntryTest.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      It "proxy Invoke-CommandTest." {
        $FileName="$Path\Proxy\Invoke-CommandTest.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      It "Proxy Invoke-WmiMethodTest." {
        $FileName="$Path\Proxy\Invoke-WmiMethodTest.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      It "Proxy Receive-PSSessionTest." {
        $FileName="$Path\Proxy\Receive-PSSessionTest.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      It "Proxy Where-ObjectTest." {
        $FileName="$Path\Proxy\Where-ObjectTest.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
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
        $Results[2].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', $SharedParameterSetName,'1,3')
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
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', $SharedParameterSetName,'A', '-1')
      }

      It "Function with 3 parameters and 3 positions (-1,-2,-3) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (-1,-2,-3) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (3)
        $Results[0].Severity| should be 'Error'                                                                          
        $Results[1].Severity| should be 'Error' 
        $Results[2].Severity| should be 'Error' 
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', $SharedParameterSetName,'B', '-2')
        $Results[1].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', $SharedParameterSetName,'C', '-3')
        $Results[2].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', $SharedParameterSetName,'A', '-1')
      }

      It "Function with 3 parameters and 3 positions (-1,2,3) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (-1,2,3) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', $SharedParameterSetName,'A', '-1')
        $Results[1].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', $SharedParameterSetName,'-1,2,3')
      }   
#Régle 3 : Les positions des paramètres d'un même jeu ne doivent pas être dupliqués
       
      It "Function with 3 parameters and 3 positions (1,2,1) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,2,1) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', $SharedParameterSetName,'1', 'C,A')
        $Results[1].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', $SharedParameterSetName,'1,1,2')
      }

# #Régle  4 : Les positions doivent débuter à zéro ou 1
      It "Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3)." {
        $FileName="$Path\Function with 3 parameters and 2 ParameterSet F2 (1,2) - F3 (3).ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', 'F2', '2,3')
        $Results[1].Message|should be ($RulesMessage.W_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', 'F3', '4')
      }

      It "Function Rule 4-Default." {
        $FileName="$Path\Rule 4-Default.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', $SharedParameterSetName, '2,3,4')
      }

#régle 5 : L'ensemble des positions doit être une suite ordonnée d'éléments.
      It "Function with 3 parameters and 3 positions (1,2,4) no ParameterSet." {
        $FileName="$Path\Function with 3 parameters and 3 positions (1,2,4) no ParameterSet.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', $SharedParameterSetName,'1,2,4')
      }

#régle 6: Un attribut [Parameter()] vide est inutile
      It "Function with ParameterAttribut() unnecessary." {
        $FileName="$Path\Function with ParameterAttribut() unnecessary.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_PsnUnnecessaryParameterAttribut -F 'TestParameterSet', 'A')
      }

      It "Control all rules in a file." {
        $FileName="$Path\Function invalidate 5 rules.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (16)
        $Results[0].Severity| should be 'Error' 
        $Results[1].Severity| should be 'Warning'
        $Results[2].Severity| should be 'Error'
        $Results[3].Severity| should be 'Error'
        $Results[4].Severity| should be 'Error'
        $Results[5].Severity| should be 'Error'
        $Results[6].Severity| should be 'Error'
        $Results[7].Severity| should be 'Error'
        $Results[8].Severity| should be 'Error'

        $Results[9].Severity| should be 'Warning'
        10..15|Foreach { $Results[$_].Severity| should be 'Error' }

        $Results[0].Message|should be (($RulesMessage.E_ParameterNameContainsInvalidCharacter -F 'TestParameterSet', '32Bits') + $RulesMessage.E_ParameterNameInvalidByNumber)
        $Results[1].Message|should be ($RulesMessage.W_PsnUnnecessaryParameterAttribut -F 'TestParameterSet', 'S')
        $Results[2].Message|should be ($RulesMessage.E_PsnMustHavePositivePosition -F 'TestParameterSet', 'F7','32Bits', '-3') 
        $Results[3].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F7','-3,1,3')
        $Results[4].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'F2','3', 'A,G')
        $Results[5].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'F2','1', 'q,D')
        $Results[6].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F2','1,1,2,3,3')
        $Results[7].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', $SharedParameterSetName,'1,3')
        $Results[8].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'F6','3', 'p,G')
        $Results[9].Message|should be ($RulesMessage.W_PsnParametersMustBeginByZeroOrOne -F 'TestParameterSet', 'F6', '3,3,4,5')
        $Results[10].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F6','3,3,4,5')
        $Results[11].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'F3','1', 'E,q')
        $Results[12].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F3','0,1,1,2,3')
        $Results[13].Message|should be ($RulesMessage.E_PsnDuplicatePosition -F 'TestParameterSet', 'F5','1', 'm,q,k')
        $Results[14].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F5','1,1,1,2,3')
        $Results[15].Message|should be ($RulesMessage.E_PsnPositionsAreNotSequential -F 'TestParameterSet', 'F4','1,3')
      }

#régle 7: Conflit détecté : un attribut [Parameter()] ne peut être dupliqué ou contradictoire
      It "Function Duplicate ParameterAttribut." {
        $FileName="$Path\Function Duplicate ParameterAttribut.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (3)
        0..2|% {$Results[$_].Severity| should be 'Error'}
        $Results[0].Message|should be ($RulesMessage.E_ConflictDuplicateParameterAttribut -F 'TestParameterSet','B','F2')
        $Results[1].Message|should be ($RulesMessage.E_ConflictDuplicateParameterAttribut -F 'TestParameterSet','C','F3')
        $Results[2].Message|should be ($RulesMessage.E_ConflictDuplicateParameterAttribut -F 'TestParameterSet','D','F2')
      }      
    }#context
}
