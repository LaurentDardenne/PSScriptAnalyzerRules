Import-LocalizedData -BindingVariable RulesMsg -Filename OptimizationRules.Resources.psd1 -EA Stop
                                      
#<DEFINE %DEBUG%>
#bug PSScriptAnalyzer : https://github.com/PowerShell/PSScriptAnalyzer/issues/599
Import-module Log4Posh
 
$Script:lg4n_ModuleName=$MyInvocation.MyCommand.ScriptBlock.Module.Name
   #Récupère le code d'une fonction publique du module Log4Posh (Prérequis)
   #et l'exécute dans la portée du module
$sb=[scriptblock]::Create("${function:Initialize-Log4NetModule}")
&$sb $Script:lg4n_ModuleName "$psScriptRoot\OptimizeRulesLog4Posh.Config.xml" $psScriptRoot
#<UNDEF %DEBUG%>   


Function NewDiagnosticRecord{
 param ($Message,$Severity,$Ast)
 [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new($Message,
                                                                             $Ast.Extent,
                                                                             $PSCmdlet.MyInvocation.InvocationName,
                                                                             $Severity,
                                                                             $null)
}

<#
.SYNOPSIS
  Informs about the for loop statement that may be improved.

.DESCRIPTION
  Avoid in each iteration to count the number of element of a collection.

.EXAMPLE
  Measure-OptimizeForSatement $ForStatementAst
    
.INPUTS
  [System.Management.Automation.Language.ForStatementAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
   
.NOTES
  None
  Inspired by :
  http://www.old.dougfinke.com/blog/index.php/2011/01/16/make-your-powershell-for-loops-4x-faster/
#>
Function Measure-OptimizeForSatement{

 [CmdletBinding()]
 [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

 Param(
       [Parameter(Mandatory = $true)]
       [ValidateNotNullOrEmpty()]
       [System.Management.Automation.Language.ForStatementAst]
      $ForStatementAst
 )

process { 
  $DebugLogger.PSDebug("Check ForStatement") #<%REMOVE%>
  try
  {
      #Analyse une instruction For()
      #On  ne traite que la propriété Condition
      #
      #Seul les trois écritures suivantes sont prises en compte :
      #   $i -lt $Range.Count
      #   $i -lt $Range.Count-1
      #   $i -lt ($Range.Count-1) 
      #   $i -lt (-1+$Range.count) écriture possible mais n'est pas prise en compte  
    if ($ForStatementAst.Condition -ne $null)
    {
      foreach ($Node in $ForStatementAst.Condition.PipelineElements)
      {
         if ( $Node -is [System.Management.Automation.Language.CommandExpressionAst] )
         {
           
           $Expression=$Node.Expression
           $DebugLogger.PSDebug("Found  Expression=$Expression") #<%REMOVE%> 
           if ($Expression -is [System.Management.Automation.Language.BinaryExpressionAst])
           {  
             $DebugLogger.PSDebug("Right=$($Expression.Right.gettype())") #<%REMOVE%>
             $RightNodeType=$Expression.Right.GetType().Name
             $DebugLogger.PSDebug("`t -> switch $RightNodeType") #<%REMOVE%>
             $CreateObject=$true
             switch ($RightNodeType) { 
               'MemberExpressionAst'   {  # cas : $I -le $Range.Count
                                          NewDiagnosticRecord $RulesMsg.I_ForStatementCanBeImproved  Information $ForStatementAst
                                       } #MemberExpressionAst 
                                       
               'BinaryExpressionAst'   { # cas : $I -le $Range.Count-1
                                          NewDiagnosticRecord $RulesMsg.I_ForStatementCanBeImproved Information $ForStatementAst                                      
                                       } #BinaryExpressionAst                                     
                 
               'ParenExpressionAst'   { # cas : $I -le ($Range.Count-1)  
                                        foreach ($RNode in $Expression.Right.Pipeline.PipelineElements)
                                        {
                                            if ( $RNode -is [System.Management.Automation.Language.CommandExpressionAst] )
                                            {
                                               $RExpression=$RNode.Expression
                                               if ($RExpression -is [System.Management.Automation.Language.BinaryExpressionAst])
                                               { NewDiagnosticRecord $RulesMsg.I_ForStatementCanBeImproved Information $ForStatementAst } 
                                            }#CommandEx 
                                        }#Foreach
                                      } #ParenExpressionAst
             }#switch
           }#BinaryEx 
         }#CommandEx      
      }#Foreach
    }#If condition    
  }
  catch
  {
     $ER= New-Object -Typename System.Management.Automation.ErrorRecord -Argumentlist $_.Exception, 
                                                                             "DetectingErrorsInDefaultParameterSetName-$FunctionName", 
                                                                             "NotSpecified",
                                                                             $FunctionDefinitionAst
     $DebugLogger.PSFatal($_.Exception.Message,$_.Exception) #<%REMOVE%>
     $PSCmdlet.ThrowTerminatingError($ER) 
  }       
 }#process
}#Measure-OptimizeForSatement


#<DEFINE %DEBUG%> 
Function OnRemoveParameterSetRules {
  Stop-Log4Net $Script:lg4n_ModuleName
}#OnRemoveParameterSetRules
 
# Section  Initialization
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveParameterSetRules }
#<UNDEF %DEBUG%>   
 
Export-ModuleMember -Function Measure-OptimizeForSatement