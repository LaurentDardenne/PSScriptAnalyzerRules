Import-LocalizedData -BindingVariable RulesMsg -Filename OptimizationRules.Resources.psd1 -ErrorAction Stop
                                      
  #<DEFINE %DEBUG%>
  #bug PSScriptAnalyzer : https://github.com/PowerShell/PSScriptAnalyzer/issues/599
  Import-Module Log4Posh
   
  $Script:lg4n_ModuleName=$MyInvocation.MyCommand.ScriptBlock.Module.Name
     #Récupère le code d'une fonction publique du module Log4Posh (Prérequis)
     #et l'exécute dans la portée du module
  $InitializeLogging=[scriptblock]::Create("${function:Initialize-Log4NetModule}")
  $Params=@{
    RepositoryName = $Script:lg4n_ModuleName
    XmlConfigPath = "$psScriptRoot\OptimizationRulesLog4Posh.Config.xml"
    DefaultLogFilePath = "$psScriptRoot\Logs\$Script:lg4n_ModuleName.log"
  }
  &$InitializeLogging @Params
  #<UNDEF %DEBUG%>   

Function NewCorrectionExtent{
 param ($Extent,$Text,$Description)

[Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent]::new(
    #Informations d’emplacement
  $Extent.StartLineNumber, 
  $Extent.EndLineNumber,
  $Extent.StartColumnNumber,
  $Extent.EndColumnNumber, 
   #Texte de la correction lié à la régle
  $Text, 
    #Nom du fichier concerné
  $Extent.File,                
    #Description de la correction
  $Description
 )
}

Function NewDiagnosticRecord{
 param ($Ast,$Correction=$null)

 $Extent=$Ast.Extent

 [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]::new(
    $RulesMsg.I_ForStatementCanBeImproved,
    $Extent,
     #RuleName
    'ForStatementCanBeImproved',
    'Information',
     #ScriptPath
    $Extent.File,
     #RuleID 
    $null,
    $Correction
 )
}
 
<#
.SYNOPSIS
  Informs about the for loop statement that may be improved.

.DESCRIPTION
  Avoid in each iteration to count the number of element of a collection.
  Inspired by :
  http://www.old.dougfinke.com/blog/index.php/2011/01/16/make-your-powershell-for-loops-4x-faster/

.EXAMPLE
  Measure-OptimizeForStatement $ForStatementAst
    
.INPUTS
  [System.Management.Automation.Language.ForStatementAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
#>
Function Measure-OptimizeForStatement{

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
    if ($null -ne $ForStatementAst.Condition)
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
             switch ($RightNodeType) { 
                 # cas : $I -le $Range.Count
               'MemberExpressionAst'   { NewDiagnosticRecord $ForStatementAst }  
                                       
                 # cas : $I -le $Range.Count-1
               'BinaryExpressionAst'   { NewDiagnosticRecord $ForStatementAst }                     
                 
                 # cas : $I -le ($Range.Count-1)
               'ParenExpressionAst'   {   
                                        foreach ($RNode in $Expression.Right.Pipeline.PipelineElements)
                                        {
                                            if ( $RNode -is [System.Management.Automation.Language.CommandExpressionAst] )
                                            {
                                               $RExpression=$RNode.Expression
                                               if ($RExpression -is [System.Management.Automation.Language.BinaryExpressionAst])
                                               { NewDiagnosticRecord $ForStatementAst } 
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
                                                                             "OptimizeForSatement-$($ForStatementAst.Extent.File)", 
                                                                             "NotSpecified",
                                                                             $FunctionDefinitionAst
     $DebugLogger.PSFatal($_.Exception.Message,$_.Exception) #<%REMOVE%>
     $PSCmdlet.ThrowTerminatingError($ER) 
  }       
 }#process
}#Measure-OptimizeForStatement


#<DEFINE %DEBUG%> 
Function OnRemoveParameterSetRules {
  Stop-Log4Net $Script:lg4n_ModuleName
}#OnRemoveParameterSetRules
 
# Section  Initialization
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveParameterSetRules }
#<UNDEF %DEBUG%>   

#Export-ModuleMember -Function Measure-OptimizeForStatement
   