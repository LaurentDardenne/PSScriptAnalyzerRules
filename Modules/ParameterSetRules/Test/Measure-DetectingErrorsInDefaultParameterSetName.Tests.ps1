$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path

$M=Import-module ..\ParameterSetRules.psd1 -Pass

$RulesMessage=&$m {$RulesMsg}

 #Todo : Copy a default xml config to disable traces on the console.

Describe "Rule DetectingErrorsInDefaultParameterSetName " {
     $Path=".\DefaultParameterSetName"
     $CustomRulePath="..\ParameterSetRules.psd1"          

    Context "When there is no violation" {

       It "DPS is used, there are three ParameterSet." {
        $FileName="$Path\DPS and ParameterSet correct.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (0)
      }
      
      It "Neither DPS (DefaultParameterSet) nor ParameterSet." {
        $FileName="$Path\Simple without DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
        
        $Results = Invoke-ScriptAnalyzer @Params
         #todo vide ou null ?
        $Results.Count | should be (0)
      }

      It "DPS is used, it is only one ParameterSet." {
        $FileName="$Path\Simple with DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      }

      It "No DPS, there is only one ParameterSet." {
        $FileName="$Path\Only one parameterset without DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_PsnRedundant -F 'TestParameterSet')
      }

      It "DPS is used, there is only one ParameterSet." {
        $FileName="$Path\Only one parameterset with DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_PsnRedundant -F 'TestParameterSet')
      } 
    }#context

   
    Context "When there is no violation, but Warning" {

      It "No DPS, there are three ParameterSet." {
        $FileName="$Path\Three parameterset without DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
      }

      It "The name of a parameterset is '__AllParameterSets'." {
        $FileName="$Path\One parameterset use '__AllParameterSets' name with DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_DpsAvoid_AllParameterSets_Name -F 'TestParameterSet')
      }
    }#context
    
    Context "When there are violations" {

      It "DPS is not used, there are three parameterset." {
        $FileName="$Path\Three parameterset - DPS is not used.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
      }

      It "DPS is used, there are three parameterset, one is a wrong by case." {
        $FileName="$Path\CaseSensitive-DPS is used.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','fonctionnalite2')
      } 
      
      It "The default parameterset name is '__AllParameterSets' and it is not used." {
        $FileName="$Path\DPS use '__AllParameterSets' Name.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsAvoid_AllParameterSets_Name  -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_DpsInused  -F 'TestParameterSet')
      }

      It "No DPS, three parameterset, one is a wrong by case." {
        $FileName="$Path\CaseSensitive-without DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','fonctionnalite1')
      }

      It "No DPS, There are two parameterset instead only one, one is a wrong by case." {
        $FileName="$Path\CaseSensitive-only one parameterset without DPS.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','fonctionnalite1')
      }

      It "No DPS, There are three parameterset, one is a wrong by case." {
        $FileName="$Path\CaseSensitive-DPS-is not used.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Fonctionnalite3')
      }

      It "DPS declared and it is a wrong by case, there are three parameterset." {
        $FileName="$Path\CaseSensitive-DPS is casesensitive-but not used.ps1"
        $Params=@{
          Path=$Filename
          CustomRulePath=$CustomRulePath          
        }
  
        $Results = Invoke-ScriptAnalyzer @Params
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Fonctionnalite3')
      }
    }#context
}
