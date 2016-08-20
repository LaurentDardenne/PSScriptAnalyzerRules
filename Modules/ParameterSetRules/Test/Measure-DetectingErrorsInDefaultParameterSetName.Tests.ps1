$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{ 
  $M=Import-module "$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psd1" -Pass 
  
  $Path="$env:APPVEYOR_BUILD_FOLDER\Modules\ParameterSetRules\Test\DefaultParameterSetName"
  $CustomRulePath="$PSScriptAnalyzerRulesDelivery\ParameterSetRules.psm1"
}
else
{ 
  $M=Import-module ..\ParameterSetRules.psd1 -Pass
  $Path=".\DefaultParameterSetName"
  $CustomRulePath="..\ParameterSetRules.psm1"  
}


$RulesMessage=&$m {$RulesMsg}

 #Todo : Copy a default xml config to disable traces on the console.

Describe "Rule DetectingErrorsInDefaultParameterSetName " {

    Context "When there is no violation" {

#<%Use case %> Function no param() ,no cmdletbinding
       It "Function no param() ,no cmdletbinding." {
        $FileName="$Path\Function no param() ,no cmdletbinding.ps1"
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

#<%Use case %> Function param() empty
       It "Function with a param statement empty." {
        $FileName="$Path\Function param() empty.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath        
        $Results.Count | should be (0)
      }

#<%Use case %> Function param() empty, cmdletbinding not filled
       It "Function param() empty, cmdletbinding not filled." {
        $FileName="$Path\Function param() empty, cmdletbinding not filled.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

#<%Use case %> Function param() empty, cmdletbinding DPS filled with 'Name1'
       It "Function param() empty, cmdletbinding DPS filled with 'Name1'." {
        $FileName="$Path\Function param() empty, cmdletbinding DPS filled with 'Name1'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      }      

#<%Use case %> Function with 5 parameters and 3 ParameterSet, cmdletbinding filled
      It "Function with 5 parameters and 3 ParameterSet, cmdletbinding filled." {
        $FileName="$Path\Function with 5 parameters and 3 ParameterSet, cmdletbinding filled.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }
      
#<%Use case %> Function with 1 parameter no ParameterSet, no cmdletbinding
      It "Function with 1 parameter no ParameterSet, no cmdletbinding." {
        $FileName="$Path\Function with 1 parameter no ParameterSet, no cmdletbinding.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

#<%Use case %> Function with 1 parameter no ParameterSet, cmdletbinding not filled
      It "Function with 1 parameter no ParameterSet, cmdletbinding not filled." {
        
        $FileName="$Path\Function with 1 parameter no ParameterSet, cmdletbinding not filled.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }

#<%Use case %> Function with 1 parameter no ParameterSet, cmdletbinding DPS filled with 'Name1'
      It "Function with 1 parameter no ParameterSet, cmdletbinding DPS filled with 'Name1'." {
        
        $FileName="$Path\Function with 1 parameter no ParameterSet, cmdletbinding DPS filled with 'Name1'.ps1"
  
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      }

#<%Use case %> Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding not filled
      It "Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding not filled." {
        $FileName="$Path\Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding not filled.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_PsnRedundant -F 'TestParameterSet')
      }

#<%Use case %> Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name1'
      It "Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name1'." {
        $FileName="$Path\Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name1'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Information'
        $Results[1].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_PsnRedundant -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      } 

#<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name1'
      It "Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name1'." {
        $FileName="$Path\Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name1'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Information'
        $Results[1].Severity| should be 'Information'
        $Results[0].Message|should be ($RulesMessage.I_PsnRedundant -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.I_DpsUnnecessary -F 'TestParameterSet')
      } 

#<%Use case %> Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name2'
      It "Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name2'." {
        $FileName="$Path\Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name2'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (0)
      }     

    }#context


   
    Context "When there is no violation, but Warning" {

#<%Use case %> Function with 2 parameters and 2 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name2' 
      It "Function with 2 parameters and 2 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name2'." {
        $FileName="$Path\Function with 2 parameters and 2 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'Name2'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
      }    

#<%Use case %> Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding not filled            
      It "Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding not filled." {
        $FileName="$Path\Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding not filled.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
      }   

#<%Use case %> Function with 5 parameters and 3 ParameterSet, cmdletbinding filled and one ParameterSet use '__AllParameterSets' 
      It "Function with 5 parameters and 3 ParameterSet, cmdletbinding filled and one ParameterSet use '__AllParameterSets'." {
        $FileName="$Path\Function with 5 parameters and 3 ParameterSet, cmdletbinding filled and one ParameterSet use '__AllParameterSets'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_DpsAvoid_AllParameterSets_Name -F 'TestParameterSet')        
        
      }  
#<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','Name2', cmdletbinding not filled
      It "Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding not filled." {
        $FileName="$Path\Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding not filled.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Warning'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
      }             
    }#context


    
    Context "When there are violations" {
      
#<%Use case %> Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name2'
      It "Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name2'." {
        $FileName="$Path\Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'Name2'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
      }            

#<%Use case %> Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive
      It "Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive." {
        $FileName="$Path\Function with 1 parameter and 1 ParameterSet 'Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1')
      }

#<%Use case %> Function with 1 parameter and 1 ParameterSet 'name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive
      It "Function with 1 parameter and 1 ParameterSet 'name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive." {
        $FileName="$Path\Function with 1 parameter and 1 ParameterSet 'name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1')
      }

#<%Use case %> Function with 2 parameters and 3 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name3'
      It "Function with 2 parameters and 3 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name3'." {
        $FileName="$Path\Function with 2 parameters and 3 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'Name3'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
      }
 #<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive
       It "Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive" {
        $FileName="$Path\Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name1' BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
        $Results[0].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1,Name1')
      } 

 #<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive - 2
       It "Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive - 2" {
        $FileName="$Path\Function with 2 parameters and 1 ParameterSet 'Name1','Name1', cmdletbinding DPS filled with 'name1' BUT case sensitive - 2.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')        
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1')
      } 

#<%Use case %> Function with 5 parameters and 3 ParameterSet, cmdletbinding filled with '__AllParameterSets'      
      It "Function with 5 parameters and 3 ParameterSet, cmdletbinding filled with '__AllParameterSets'." {
        $FileName="$Path\Function with 5 parameters and 3 ParameterSet, cmdletbinding filled with '__AllParameterSets'.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsAvoid_AllParameterSets_Name  -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_DpsInused  -F 'TestParameterSet')
      }

#<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS not filled BUT case sensitive
      It "Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS not filled BUT case sensitive." {
        $FileName="$Path\Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS not filled BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1')
      }

#<%Use case %> Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name2' BUT case sensitive
      It "Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name2' BUT case sensitive." {
        $FileName="$Path\Function with 2 parameters and 1 ParameterSet 'Name1','name1', cmdletbinding DPS filled with 'Name2' BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name1,name1')
      }

#<%Use case %> Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'name2' BUT case sensitive
      It "Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'name2' BUT case sensitive." {
        $FileName="$Path\Function with 2 parameters and 2 ParameterSet 'Name1','Name2', cmdletbinding DPS filled with 'name2' BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Error'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.E_DpsInused -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','Name2,name2')
      }

#<%Use case %> Function with 4 parameters and 2 ParameterSet 'text,'Text',TEXT','notext', cmdletbinding not filled BUT case sensitive
      It "Function with 4 parameters and 2 ParameterSet 'text,'Text',TEXT','notext', cmdletbinding not filled BUT case sensitive." {
        $FileName="$Path\Function with 4 parameters and 2 ParameterSet 'text,'Text',TEXT','notext', cmdletbinding not filled BUT case sensitive.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
        $Results[0].Severity| should be 'Warning'
        $Results[1].Severity| should be 'Error'
        $Results[0].Message|should be ($RulesMessage.W_DpsNotDeclared -F 'TestParameterSet')
        $Results[1].Message|should be ($RulesMessage.E_CheckPsnCaseSensitive -F 'TestParameterSet','text,Text,TEXT')
      }
    }#context
}
