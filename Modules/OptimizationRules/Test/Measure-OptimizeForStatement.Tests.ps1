$global:here = Split-Path -Parent $MyInvocation.MyCommand.Path

if (Test-Path env:APPVEYOR_BUILD_FOLDER)
{ 
  $M=Import-module "$PSScriptAnalyzerRulesDelivery\OptimizationRules.psd1" -Pass 
  
  $Path="$env:APPVEYOR_BUILD_FOLDER\Modules\OptimizationRules\Test"
  $CustomRulePath="$PSScriptAnalyzerRulesDelivery\OptimizationRules.psm1"
}
else
{ 
  $M=Import-module ..\OptimizationRules.psd1 -Pass
  $Path="."
  $CustomRulePath="..\OptimizationRules.psm1"  
}

$testCasesWithOut = @(
@{Name='SuppressMessageBinaryExpressionAst.ps1'};
@{Name='NOBinaryExpressionAst.ps1'};
@{Name='NOMemberExpressionAst.ps1'};
@{Name='NOParenExpressionAst.ps1'};
@{Name='NOParenExpressionAst2.ps1'}
)

$testCasesWith = @(
@{Name='BinaryExpressionAst.ps1'};
@{Name='MemberExpressionAst.ps1'};
@{Name='ParenExpressionAst.ps1'}
)

$RulesMessage=&$m {$RulesMsg}

Describe "Rule OptimizationRules" {

    Context "When there is no optimization" {

       It "ScriptAnalyze return no result." -TestCases $testCasesWithOut {
        param($Name)
         Write-Host "Name : $Name"
         $FileName="$Path\$Name"
         $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
         $Results.Count | should be (0)
      }
    }#context

    Context "When there are optimization" {
      
      It "ScriptAnalyze return result." -TestCases $testCasesWith{
        param($Name)
         Write-Host "Name : $Name"
         $FileName="$Path\$Name"
        
         $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
         $Results.Count | should be (1)
         $Results[0].Severity| should be 'Information'
         $Results[0].Message|should be $RulesMessage.I_ForStatementCanBeImproved
      } 

      It "ScriptAnalyze return result from a script." -TestCases $testCasesWith{
        $FileName="$Path\ParenExpressionAst2.ps1"
        
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (2)
      }   
    
      It "ScriptAnalyze return result from a fonction." -TestCases $testCasesWith{
        $FileName="$Path\ParenExpressionAst3.ps1"
        $Results = Invoke-ScriptAnalyzer -Path $Filename -CustomRulePath $CustomRulePath
        $Results.Count | should be (1)
      }                
    }#context
}
