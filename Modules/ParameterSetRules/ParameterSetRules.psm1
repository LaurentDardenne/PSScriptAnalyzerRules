#<%ScriptAnalyzer categories%>. Tag : PSScriptAnalyzer, PSScriptAnalyzerRule, Analyze, Rule

Import-LocalizedData -BindingVariable RulesMsg -Filename ParameterSetRules.Resources.psd1 -EA Stop
                                      
#Todo : add build with Remove-Conditionnal (psm1 + psd1)
#Todo Test-OutputTypeAttribut -> ParameterSetName inused or case sensitive

#<DEFINE %DEBUG%>
#bug PSScriptAnalyzer : https://github.com/PowerShell/PSScriptAnalyzer/issues/599
Import-module Log4Posh
 
$Script:lg4n_ModuleName=$MyInvocation.MyCommand.ScriptBlock.Module.Name
   #Récupère le code d'une fonction publique du module Log4Posh (Prérequis)
   #et l'exécute dans la portée du module
$sb=[scriptblock]::Create("${function:Initialize-Log4NetModule}")
&$sb $Script:lg4n_ModuleName "$psScriptRoot\ParameterSetRulesLog4Posh.Config.xml" $psScriptRoot
#<UNDEF %DEBUG%>   

$script:Helpers=[Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper]::new($MyInvocation.MyCommand.ScriptBlock.Module.SessionState.InvokeCommand,$null)

function Get-CommonParameters{ 
  [System.Management.Automation.Internal.CommonParameters].GetProperties().Names
}#Get-CommonParameters

[string[]]$script:CommonParameters=Get-CommonParameters

$script:CommonParametersFilter= { $script:CommonParameters -notContains $_.Name}

#todo
$script:Helpers=[Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper]::new($MyInvocation.MyCommand.ScriptBlock.Module.SessionState.InvokeCommand,$null)


Function NewDiagnosticRecord{
 param ($Message,$Severity)
 #caution : use the parent scope
 
   #DiagnosticRecord(string message, IScriptExtent extent, string ruleName, DiagnosticSeverity severity, 
   #                 string scriptPath, string ruleId = null, List<CorrectionExtent> suggestedCorrections = null)
 New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
             -ArgumentList $Message,$FunctionDefinitionAst.Extent,
             $PSCmdlet.MyInvocation.InvocationName,$Severity,$null
}

function TestSequential{
#La collection doit être triée
param([int[]]$List)
  $Count=$List.Count
  for ($i = 1; $i -lt $Count; $i++)
  {
     if ($List[$i] -ne $List[$i - 1] + 1)
     {return $false}
  }
  return $true
}# TestSequential


<#
.SYNOPSIS
    Detecting errors in DefaultParameterSetName

.DESCRIPTION
   Détermine si le nom du paramètre DefaultParameterSetName, de l'attribut 
   CmdletBinding, est présent dans la liste des noms de jeux de paramètre. 
.
   Si DefaultParameterSetName n'est pas utilisé, cette fonction renvoie $true.
.   
   Si DefaultParameterSetName est utilisé et qu'aucun autre jeu de paramètre 
   n'est déclaré, cette fonction renvoie $true.
.
   Si DefaultParameterSetName est utilisé et que son contenu ne correspond à 
   aucun nom de jeu de paramètre déclaré, cette fonction renvoie $false.
   Ce test est sensible à la casse.
   Le jeux de paramètre nommé 'Setup' est différent de celui nommé 'setup'.

.EXAMPLE
   Measure-DetectingErrorsInDefaultParameterSetName $FunctionDefinitionAst
    
.INPUTS
  [System.Management.Automation.Language.FunctionDefinitionAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
   
.NOTES
  None
  Bug https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11088147-parameterset-names-should-not-be-case-sensitive
#>
Function Measure-DetectingErrorsInDefaultParameterSetName{

 [CmdletBinding()]
 [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

 Param(
       [Parameter(Mandatory = $true)]
       [ValidateNotNullOrEmpty()]
       [System.Management.Automation.Language.FunctionDefinitionAst]
      $FunctionDefinitionAst
 )

process { 
  $FunctionName=$FunctionDefinitionAst.Name
  $DebugLogger.PSDebug("$('-'*40)") #<%REMOVE%>
  $DebugLogger.PSDebug("Check the function '$FunctionName'") #<%REMOVE%>
  try
  {
    $Result=New-object System.Collections.Arraylist
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
    $DebugLogger.PSDebug("ParamBlock.Attributes.Count: $($ParamBlock.Attributes.Count)") #<%REMOVE%>
    
      #note: si plusieurs attributs [CmdletBinding] existe, la méthode CmdletBinding() renvoi le premier trouvé 
    $CBA=$script:Helpers.GetCmdletBindingAttributeAst($ParamBlock.Attributes)
    $DPS_Name=$CBA.NamedArguments.Where({$_.ArgumentName -eq 'DefaultParameterSetName'}).Argument.Value
  
      #Récupère les noms de jeux 
      #Les paramètres communs sont dans le jeu nommé '__AllParameterSets' créé à l'exécution
    [string[]] $ParameterSets=$ParamBlock.Parameters.Attributes.NamedArguments.Where({$_.ArgumentName -eq 'ParameterSetName'}).Argument.Value|
                    Select-Object -Unique
    $SetCount=$ParameterSets.Count
  
    $DebugLogger.PSDebug("DefaultParameterSet is set ? $($null -ne $DPS_Name)") #<%REMOVE%>
    $DebugLogger.PSDebug("DefaultParameterSet name= $DPS_Name") #<%REMOVE%>    
    $DebugLogger.PSDebug("Number of parameter set : $SetCount") #<%REMOVE%>
     $DebugLogger.PSDebug("parameter set : $ParameterSets") #<%REMOVE%>
    
    if (($null -eq $DPS_Name) -and ($SetCount -eq 0 ))
    { return } #Nothing to do                                                                           
    
    if (($null -eq $DPS_Name) -and ($SetCount -gt 1))
    {  
       #todo : Pour certaines constructions basées sur les paramètres obligatoire (ex: Pester.Set-ScriptBlockScope) #<%REMOVE%>
       #       ce warning ne devrait pas se déclencher.                                                             #<%REMOVE%>
      $result.Add((NewDiagnosticRecord ($RulesMsg.W_DpsNotDeclared -F $FunctionName) Warning)) > $null 
    } 

    # Les cas I_PsnRedundant et I_DpsUnnecessary sont similaires                                                      
    # Pour I_PsnRedundant il y a 1,n déclarations redondantes mais pour I_DpsUnnecessary il y a 1 déclaration inutile
    if ((($null -ne $DPS_Name) -and ($SetCount -eq 1) -and ($DPS_Name -ceq  $ParameterSets[0])) -or (($null -eq $DPS_Name) -and ($SetCount -eq 1))) 
    {       
       $DebugLogger.PSDebug("PSN redondant.") #<%REMOVE%>
       $result.Add((NewDiagnosticRecord ($RulesMsg.I_PsnRedundant -F $FunctionName) Information )) > $null
    }
    
    if (@($ParameterSets;$DPS_Name) -eq [System.Management.Automation.ParameterAttribute]::AllParameterSets)
    { 
       $DebugLogger.PSDebug("Le nom est '__AllParameterSets', ce nommage est improbable, mais autorisé") #<%REMOVE%>
       $result.Add((NewDiagnosticRecord ($RulesMsg.W_DpsAvoid_AllParameterSets_Name -F $FunctionName) Warning )) > $null
    }

    if ($null -ne $DPS_Name) 
    {       
       if (($SetCount -eq  0) -or (($SetCount -eq  1) -and ($DPS_Name -ceq  $ParameterSets[0])))
       {
          $DebugLogger.PSDebug("Dps seul est inutile") #<%REMOVE%>
          $result.Add((NewDiagnosticRecord ($RulesMsg.I_DpsUnnecessary -F $FunctionName) Information )) > $null
       }
       else 
       {       
          $DebugLogger.PSDebug("Test sur la cohérence et sur la casse: $ParameterSets") #<%REMOVE%>
          if (($ParameterSets.count -gt 0) -and ($DPS_Name -cnotin $ParameterSets))
          {
            $DebugLogger.PSDebug("Dps inutilisé") #<%REMOVE%>
            $result.Add((NewDiagnosticRecord ($RulesMsg.E_DpsInused -F $FunctionName) Error)) > $null
          }
       }
    }
    if (($SetCount -gt 1) -or (($null -ne $DPS_Name) -and ($SetCount -eq  1)))
    {
       $ParameterSets += $DPS_Name    
       $CaseSensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCulture)
       $CaseInsensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCultureIgnoreCase)
       
       $DebugLogger.PSDebug("Sensitive : $CaseSensitive") #<%REMOVE%>
       $DebugLogger.PSDebug("Insensitive : $CaseInsensitive") #<%REMOVE%> 
       
       if ($CaseSensitive.Count -ne $CaseInsensitive.Count)
       {
         $DebugLogger.PSDebug("Parameterset dupliqué à cause de la casse") #<%REMOVE%>
         $CBAExtent=$CBA.Extent
         $Correction=New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent" `
          -ArgumentList  $CBAExtent.StartLineNumber, $CBAExtent.EndLineNumber,$CBAExtent.StartColumnNumber,
                         $CBAExtent.EndColumnNumber, $FunctionDefinitionAst.Name, $FunctionDefinitionAst.Extent.File,                
                         ($RulesMsg.Correction_CheckPsnCaseSensitive  -F $FunctionName)
         $ofs=','
         $CaseSensitive.ExceptWith($CaseInsensitive)
         $DebugLogger.PSDebug("ExceptWith: $CaseSensitive") #<%REMOVE%>
         $DebugLogger.PSDebug("ExceptWith : $CaseInsensitive") #<%REMOVE%>
         $result.Add((New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
                     -ArgumentList ($RulesMsg.E_CheckPsnCaseSensitive -F $FunctionName,"$($ParameterSets -eq ($CaseSensitive|Select-Object -first 1))"),
                                   $FunctionDefinitionAst.Extent,$PSCmdlet.MyInvocation.InvocationName,Error,$null,$null,$Correction)) > $null
       }  
    } 
    return $result
  }
  catch
  {
     $PSCmdlet.ThrowTerminatingError($PSItem)
  }       
 }#process
}#Measure-DetectingErrorsInDefaultParameterSetName

# #todo à adapter
Function Measure-DetectingErrorsInParameterList{         
<#
.SYNOPSIS
   Détermine si les jeux de paramètres d'une commande sont valides.
   Un jeux de paramètres valide :
   les numéros de positions de ses paramètres doivent se suivre et ne pas être dupliqué.
   Les noms de paramètres débutant par un chiffre invalideront le test.
#>  
 [CmdletBinding()]
 [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]

 Param(
       [Parameter(Mandatory = $true)]
       [ValidateNotNullOrEmpty()]
       [System.Management.Automation.Language.FunctionDefinitionAst]
      $FunctionDefinitionAst
 )

process { 
  $FunctionName=$FunctionDefinitionAst.Name
  $DebugLogger.PSDebug("$('-'*40)") #<%REMOVE%>
  $DebugLogger.PSDebug("Check the function '$FunctionName'") #<%REMOVE%> 

  $_AllNames=@($Cmd.ParameterSets|
            Foreach {
              $PrmStName=$_.Name
              $P=$_.Parameters|Foreach {$_.Name}|Where  {$_ -notin $script:CommonParameters} 
              $DebugLogger.PSDebug("Build $PrmStName $($P.Count)") #<%REMOVE%>
              if (($P.Count) -eq 0)
              { Write-Warning "[$($Cmd.Name)]: the parameter set '$PrmStName' is empty." } #todo logger
              $P
            })

  $Sets=[psCustomObject]@{
     PSTypename='TestParameterSetInformation'
     CommandName=$Cmd.Name
     Set=new-object System.Collections.ArrayList
     isValid=$false
  }                          
  if ($_AllNames.Count -eq 0 ) 
  { return $Sets  }
   
   #Contient les noms des paramètres de tous les jeux
   #Les noms peuvent être dupliqués
  $AllNames=new-object System.Collections.ArrayList(,$_AllNames)
  
  $Cmd.ParameterSets| 
   foreach {
     $Name=$_.Name
     $DebugLogger.PSDebug("Current ParemeterSet $Name") #<%REMOVE%>
     $InvalidParametersName=new-object System.Collections.ArrayList
      #Contient tous les noms de paramètre du jeux courant
     $Params=new-object System.Collections.ArrayList
      #Contient les positions des paramètres du jeux courant
     $Positions=new-object System.Collections.ArrayList
     $Others=$AllNames.Clone()
     
     $_.Parameters|
      Where {$_.Name -notin $script:CommonParameters}|
      Foreach {
        $ParameterName=$_.Name
        $DebugLogger.PSDebug("Add $ParameterName $($_.Position)") #<%REMOVE%>
        $Params.Add($ParameterName) > $null
        $Positions.Add($_.Position) > $null
         #Toutes les constructions ne sont pas testées
         #par exemple les noms d'opérateur, cela fonctionne mais rend le code légérement obscur
         #todo pas d'espace au début ou en fin
         #todo ${global:test}
         #todo ne pas contenir de point
        if (($ParameterName -match "^\d|-|\+|%|&" ) -or ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($ParameterName)))
        { 
          $DebugLogger.PSDebug("Invalide parameter name '$ParameterName'") #<%REMOVE%>
          $InvalidParametersName.Add($ParameterName) > $null 
        }         
      }
     
      #Supprime dans la collection globale
      #les noms de paramètres du jeux courant
     $Params| 
      Foreach { 
        $DebugLogger.PSDebug("Remove $_") #<%REMOVE%>
        $Others.Remove($_) 
      }

      #Supprime les valeurs des positions par défaut
     $FilterPositions=$Positions|Where {$_ -ge 0}
      #Get-Unique attend une collection triée
     $SortedPositions=$FilterPositions|Sort-Object  
     $isDuplicate= -not (@($SortedPositions|Get-Unique).Count -eq $FilterPositions.Count)
     $isSequential= TestSequential $SortedPositions
     
     $isPositionValid=($isDuplicate -eq $False) -and ($isSequential -eq $true)
     #TODO : faux en V5 
     #-> cf Method private System.Management.Automation.CmdletParameterBinderController.ValidateParameterSets
     $HasParameterUnique= &{
         if ($Others.Count -eq 0 ) 
         { 
           $DebugLogger.PSDebug("Only one parameter set.") #<%REMOVE%>
           return $true
         }
         foreach ($Current in $Params)
         {
           if ($Current -notin $Others)
           { return $true}
         }
         return $false           
      }#$HasParameterUnique
     
     $isContainsInvalidParameter=$InvalidParametersName.Count -gt 0
            
     $O=[psCustomObject]@{
            #Mémorise les informations.
            #Utiles en cas de construction de rapport
           PSTypename='ParameterSetInformation' 
           ParameterSetName=$Name
           Params=$Params;
           Others=$Others;
           Positions=$Positions;
           InvalidParameterName=$InvalidParametersName #.Clone()
            
            #Les propriété suivantes indiquent la ou les causes d'erreur
           isHasUniqueParameter= $HasParameterUnique;

           isPositionContainsDuplicate= $isDuplicate;
            #S'il existe des nombres dupliqués, la collection ne peut pas être une suite
           isPositionSequential= $isSequential
            
           isPositionValid= $isPositionValid
           
           isContainsInvalidParameter=$isContainsInvalidParameter
           
            #La propriété suivante indique si le jeux de paramètre est valide ou pas.
           isValid= $HasParameterUnique -and $isPositionValid -and -not $isContainsInvalidParameter
         }#PSObject
     $Sets.Set.Add($O) > $null
   }#For ParameterSets
   $Sets.isValid=$null -eq ($Sets.Set|Where isValid -eq $false|Select -First 1) 
   ,$Sets
 }#process
}#Test-ParameterSet

#<DEFINE %DEBUG%> 
Function OnRemoveParameterSetRules {
  Stop-Log4Net $Script:lg4n_ModuleName
}#OnRemoveParameterSetRules
 
# Section  Initialization
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveParameterSetRules }
#<UNDEF %DEBUG%>   
 
Export-ModuleMember -Function Measure-DetectingErrorsInDefaultParameterSetName