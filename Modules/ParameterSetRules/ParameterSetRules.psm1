﻿#<%ScriptAnalyzer categories%>. Tag : PSScriptAnalyzer, PSScriptAnalyzerRule, Analyze, Rule
#guideline : Gotchas, Refactoring, PSIssue/PSBehavior

Import-LocalizedData -BindingVariable RulesMsg -Filename ParameterSetRules.Resources.psd1 -EA Stop
                                      
#Note : Code du module PS v3, code source pour PS version 2, régle différente: exemple celle de gestion des PSN 

#<DEFINE %DEBUG%> 
#todo bug PSScriptAnalyzer : https://github.com/PowerShell/PSScriptAnalyzer/issues/599
Import-module Log4Posh
 
$Script:lg4n_ModuleName=$MyInvocation.MyCommand.ScriptBlock.Module.Name

  #This code create the following variables : $script:DebugLogger, $script:InfoLogger, $script:DefaultLogFile
$InitializeLogging=[scriptblock]::Create("${function:Initialize-Log4NetModule}")
$Params=@{
  RepositoryName = $Script:lg4n_ModuleName
  XmlConfigPath = "$psScriptRoot\ParameterSetRulesLog4Posh.Config.xml"
  DefaultLogFilePath = "$psScriptRoot\Logs\${Script:lg4n_ModuleName}.log"
}
&$InitializeLogging @Params
#<UNDEF %DEBUG%>   

[string[]]$script:CommonParameters=[System.Management.Automation.Internal.CommonParameters].GetProperties().Names

$script:CommonParametersFilter= { $script:CommonParameters -notContains $_.Name}

$script:PositionDefault=[int]::MinValue
$script:SharedParameterSetName='__AllParametersSet'
$script:isSharedParameterSetName_Unique=$false


#todo
$script:Helpers=[Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper]::new($MyInvocation.MyCommand.ScriptBlock.Module.SessionState.InvokeCommand,$null)


Function NewDiagnosticRecord{
 param ($Message,$Severity,$Ast)
   #DiagnosticRecord(string message, IScriptExtent extent, string ruleName, DiagnosticSeverity severity, 
   #                 string scriptPath, string ruleId = null, List<CorrectionExtent> suggestedCorrections = null)
 New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
             -ArgumentList $Message,$Ast.Extent,
             $PSCmdlet.MyInvocation.InvocationName,$Severity,$null
}

<#
.SYNOPSIS
    Detecting errors in DefaultParameterSetName

.EXAMPLE
   Measure-DetectingErrorsInDefaultParameterSetName $FunctionDefinitionAst
    
.INPUTS
  [System.Management.Automation.Language.FunctionDefinitionAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
   
.NOTES
  See this issue : https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11088147-parameterset-names-should-not-be-case-sensitive
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
    $Result_DEIDPSN=New-object System.Collections.Arraylist 
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
    $DebugLogger.PSDebug("ParamBlock.Attributes.Count: $($ParamBlock.Attributes.Count)") #<%REMOVE%>
    
      #note: si plusieurs attributs [CmdletBinding] existe, la méthode GetCmdletBindingAttributeAst renvoi le premier trouvé 
    $CBA=$script:Helpers.GetCmdletBindingAttributeAst($ParamBlock.Attributes)
    $DPS_Name=($CBA.NamedArguments|Where-Object {$_.ArgumentName -eq 'DefaultParameterSetName'}).Argument.Value
  
      #Récupère les noms de jeux 
      #Les paramètres communs sont dans le jeu nommé '__AllParameterSets' créé à l'exécution
    [string[]] $ParameterSets=@(($ParamBlock.Parameters.Attributes.NamedArguments|Where-Object {$_.ArgumentName -eq 'ParameterSetName'}).Argument.Value|
                    Select-Object -Unique)
    $SetCount=$ParameterSets.Count

    if (($null -eq $DPS_Name) -and ($SetCount -eq 0 ))
    { return } #Nothing to do                                                                           
    
    if (($null -eq $DPS_Name) -and ($SetCount -gt 1))
    {  
       #Todo : Pour certaines constructions basées sur les paramètres obligatoire (ex: Pester.Set-ScriptBlockScope) #<%REMOVE%>
       #       ce warning ne devrait pas se déclencher.                                                             #<%REMOVE%>
       #       Reste à connaitre les spécification de la règle à coder...                                           #<%REMOVE%>
      $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.W_DpsNotDeclared -F $FunctionName) Warning $FunctionDefinitionAst)) > $null 
    } 

    # Les cas I_PsnRedundant et I_DpsUnnecessary sont similaires                                                      
    # Pour I_PsnRedundant il y a 1,n déclarations redondantes mais pour I_DpsUnnecessary il y a 1 déclaration inutile
    if ((($null -ne $DPS_Name) -and ($SetCount -eq 1) -and ($DPS_Name -ceq  $ParameterSets[0])) -or (($null -eq $DPS_Name) -and ($SetCount -eq 1))) 
    {       
       $DebugLogger.PSDebug("PSN redondant.") #<%REMOVE%>
       $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.I_PsnRedundant -F $FunctionName ) Information $FunctionDefinitionAst)) > $null
    }
    
    if (@($ParameterSets;$DPS_Name) -eq [System.Management.Automation.ParameterAttribute]::AllParameterSets)
    { 
       $DebugLogger.PSDebug("Le nom est '__AllParameterSets', ce nommage est improbable, mais autorisé.") #<%REMOVE%>
       $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.W_DpsAvoid_AllParameterSets_Name -F $FunctionName) Warning $FunctionDefinitionAst)) > $null
    }

    if ($null -ne $DPS_Name) 
    {       
       if (($SetCount -eq  0) -or (($SetCount -eq  1) -and ($DPS_Name -ceq  $ParameterSets[0])))
       {
          $DebugLogger.PSDebug("Dps seul est inutile") #<%REMOVE%>
          $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.I_DpsUnnecessary -F $FunctionName) Information $FunctionDefinitionAst)) > $null
       }
       else 
       {       
          $DebugLogger.PSDebug("Test sur la cohérence et sur la casse: $ParameterSets") #<%REMOVE%>
          if (($ParameterSets.count -gt 0) -and ($DPS_Name -cnotin $ParameterSets))
          {
            $DebugLogger.PSDebug("Dps inutilisé") #<%REMOVE%>
            $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.W_DpsInused -F $FunctionName) Warning $FunctionDefinitionAst)) > $null
          }
       }
    }
    if (($SetCount -gt 1) -or (($null -ne $DPS_Name) -and ($SetCount -eq  1)))
    {
       $ParameterSets += $DPS_Name    
       $CaseSensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCulture)
       $CaseInsensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCultureIgnoreCase)

       if ($CaseSensitive.Count -ne $CaseInsensitive.Count)
       {
         $DebugLogger.PSDebug("Parameterset dupliqué à cause de la casse") #<%REMOVE%>
         $ofs=','
         $CaseSensitive.ExceptWith($CaseInsensitive)
         $msg=$RulesMsg.E_CheckPsnCaseSensitive -F $FunctionName,"$($ParameterSets -eq ($CaseSensitive|Select-Object -First 1))"
         $Result_DEIDPSN.Add((NewDiagnosticRecord $Msg Error $FunctionDefinitionAst)) > $null
       }  
    } 
    return $Result_DEIDPSN
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
}#Measure-DetectingErrorsInDefaultParameterSetName

#---------------------------------------------------------------------------
function TestSequential{
#The Collection must be sorted
#Returns $true if the array contains an ordered sequence of numbers.
param([int[]]$List)
  
  if ($List.Count -eq 1)
  {return $true}
  
  $Count=$List.Count
  for ($i = 1; $i -lt $Count; $i++)
  {
     if ($List[$i] -ne $List[$i - 1] + 1)
     {return $false}
  }
  return $true
}# TestSequential


function GetParameter{
#build the parameters collection :
#return objects(into a hashtable) with the parameter name, the parameterset name and the position
#The key of the hashtable avoid the duplication
  param($ParamBlock, $ListDR,$Ast)
   #Un jeu de paramètres ne peut être déduit de la position
   #si aucun de ses paramètres n'est mandatory
  function AddParameter {
     param ($Name,$Psn,$Position=$script:PositionDefault)
    $DebugLogger.PSDebug("Add '$ParameterName' into '$psn'") #<%REMOVE%>
    $O=[pscustomObject]@{
     Name=$Name
     PSN=$psn
     Position=$Position
    }
    try
    {
      $Parameters.Add("$Name$Psn",$o)
    }
    catch [System.ArgumentException]{
#<DEFINE %DEBUG%> 
      #Cas correct
      #   [Parameter(Position=1)]
      #   [Parameter(ParameterSetName="F6")]
      #   $A          
      #BUG PS: 
      # une duplication de déclaration identique invalide le résultat de Get-Commande,
      # Parameters et parameterSet sont vide.
      #   
      #Erreur lors de la duplication de la déclaration :
      #   [Parameter(Position=1,ParameterSetName="F6")]
      #   [Parameter(Position=1,ParameterSetName="F6")]
      #   $A
      #Ou 
      #   [Parameter(Position=1)]
      #   [Parameter(ParameterSetName="F6")]
      #   [Parameter(Position=2)]      
      #   $A
      #ou encore
      #   [Parameter(Position=1)]
      #   [Parameter(ParameterSetName="F6")]
      #   [Parameter(ParameterSetName="F6")]      
#<UNDEF %DEBUG%>   
     #régle 7: Conflit détecté : un attribut [Parameter()] ne peut être dupliqué ou contradictoire
     $DebugLogger.PSDebug("$Name$Psn Conflit détecté : un attribut [Parameter()] ne peut être dupliqué ou contradictoire") #<%REMOVE%>
     $Result_DEIPL.Add((NewDiagnosticRecord ($RulesMsg.E_ConflictDuplicateParameterAttribut -F $FunctionName,$Name,$PSN) Error $FunctionDefinitionAst)) > $null
    }                                       
  }

  $Parameters=@{}
  $DebugLogger.PSDebug("ParamBlock.Parameters.Count: $($ParamBlock.Parameters.Count)") #<%REMOVE%>
  Foreach ($Parameter in $ParamBlock.Parameters)
  {
   $ParameterName=$Parameter.Name.VariablePath.UserPath
   $PSN=$script:SharedParameterSetName
   
    #régle 1 : un nom de paramètre ne doit pas commencer par un chiffre,
    # ni contenir certains caractères. Ceci pour les noms de paramètre ${+Name.Next*}
   $isParameterNameValid=TestParameterName $FunctionName $ParameterName $Ast 
   if ($null -ne $isParameterNameValid)  
   { $ListDR.Add((NewDiagnosticRecord $isParameterNameValid Error $Ast)) > $null   } 
               
   
   if ($Parameter.Attributes.Count -eq 0) 
   { AddParameter $ParameterName $psn }
   else
   { 
     $Predicate= { $args[0].TypeName.FullName -eq 'Parameter' }
     $All=$Parameter.Attributes.FindAll($Predicate,$true) 
     if ($null -eq $All) 
     { AddParameter $ParameterName $psn }
     else
     {
        #Si un attribut Parameter est déclaré plusieurs fois sur le même jeux
        #On gére les doublons, mais on ne considére que la première déclaration de [Parameter()] 
       foreach ($Attribute in $Parameter.Attributes)
       {
         if ($Attribute.TypeName.FullName -eq 'Parameter')
         {
           $Position=$script:PositionDefault
           if (($Attribute.NamedArguments.Count -eq 0) -and ($Attribute.PositionalArguments.Count -eq 0))
           {
             #régle 6: Un attribut [Parameter()] vide est inutile
             $DebugLogger.PSDebug("`tRule : [Parameter()] vide") #<%REMOVE%>
             $Result_DEIPL.Add((NewDiagnosticRecord ($RulesMsg.W_PsnUnnecessaryParameterAttribut -F $FunctionName,$ParameterName) Warning $FunctionDefinitionAst)) > $null
           }
           else 
           {
             foreach ($NamedArgument in $Attribute.NamedArguments)
             {
                $ArgumentName=$NamedArgument.ArgumentName
                if ($ArgumentName -eq 'ParameterSetName')
                { $PSN=$NamedArgument.Argument.Value }
                elseif ($ArgumentName -eq 'Position')
                { $Position=$NamedArgument.Argument.Value}
             }
           }
          AddParameter $ParameterName $psn $Position
        } 
       }
    }
  }  
 } 
 ,$Parameters 
}#GetParameter   

function TestParameterName{
#Control the validity of a parameter name
#see to : the rule AvoidReservedParams
 param( $FunctionName,$ParameterName)

#<DEFINE %DEBUG%>
#todo Peut couvrir tous les cas. Tests : ${global:test} ${env:Temp} ${c:\get-noun} 
#Mais on ne connait pas la cause de l'erreur
function IsSafeNameOrIdentifier{
 param([string] $name)
   # from PowerShellSource:\src\System.Management.Automation\engine\CommandMetadata.cs
 [Regex]::IsMatch($name, "^[_\?\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Lm}]{1,100}$", "Singleline,CultureInvariant")
}
#<UNDEF %DEBUG%>
  #Toutes les constructions ne sont pas testées
  # par exemple les noms d'opérateur, cela fonctionne mais rend le code légérement obscur
  $DebugLogger.PSDebug("isSafeNameOrIdentifier= $(IsSafeNameOrIdentifier $ParameterName)") #<%REMOVE%>
  if ($ParameterName -match "(?<Number>^\d)|(?<Operator>-|\+|%|&)|(?<Dot>\.)|(?<Space>^\s+|\s+$)|(?<PSWildcard>\*|\?\[\])")
  { 
    $Message=$RulesMsg.E_ParameterNameContainsInvalidCharacter -f $FunctionName,$ParameterName
    if ($matches.Contains('Number')) # ne garder que celle-ci ?
    { $reason= $RulesMsg.E_ParameterNameInvalidByNumber }
    elseif ($matches.Contains('Dot'))
    { $reason=$RulesMsg.E_ParameterNameInvalidByDot }
    elseif ($matches.Contains('Operator'))
    { $reason= $RulesMsg.E_ParameterNameInvalidByOperator }
    elseif ($matches.Contains('Space'))
    { $reason= $RulesMsg.E_ParameterNameInvalidBySpace }
    elseif ($matches.Contains('PSWildCard'))
    { $reason= $RulesMsg.E_ParameterNameInvalidByPSWildcard }
    
    $DebugLogger.PSDebug("`tRule : $Message $Reason") #<%REMOVE%>
    return "$Message$Reason"
 }         
}#TestParameterName


function TestSequentialAndBeginByZeroOrOne{
# The positions should begin to zero or 1,
# not be duplicated and be  an ordered sequence.
         
 param($FunctionName, $GroupByPSN, $Ast, $isDuplicate)
  $PSN=$GroupByPSN.Name
  $SortedPositions=$GroupByPSN.Group.Position|Where-Object {$_ -ne $script:PositionDefault}|Sort-Object
  if ($null -ne $SortedPositions)
  {
    $DebugLogger.PSDebug("psn= $PSN isUnique=$script:isSharedParameterSetName_Unique  -gt 1 $($SortedPositions[0] -gt 1)") #<%REMOVE%>
    $ofs=','
    #Régle  4 : Les positions doivent débuter à zéro ou 1
    #Il reste possible d'utiliser des numéros de position arbitraire mais au détriment de la compréhension/relecture
    #un jeu (J1) peut avoir un paramètre ayant une position 2, dans le cas où un paramètre commun (J0)  
    #indique une position 1, la régle sera validé J1=(J1+J0) puisque le paramètre commun est ajouté à chaque jeu déclaré.
   if (($SortedPositions[0] -gt 1) -and ($script:isSharedParameterSetName_Unique -or ($PSN -ne $script:SharedParameterSetName)))  
   { 
     $DebugLogger.PSDebug("`tRule : The positions of parameters must begin by zero or one -> $($SortedPositions[0])") #<%REMOVE%>
     NewDiagnosticRecord ($RulesMsg.W_PsnParametersMustBeginByZeroOrOne -F $FunctionName,$PSN,"$SortedPositions") Warning $Ast
   }
   if (-not $iDusplicate) 
   {
     #régle 5 : L'ensemble des positions doit être une suite ordonnée d'éléments.
     # Ex 1,2,3 est correct, mais pas 1,3 ou 1,2,3,1 ni 6,4,2
     # Des positions de paramètre dupliqués invalident forcément cette régle 5   
     if (-not (TestSequential $SortedPositions))
     { 
       $DebugLogger.PSDebug("`tRule : Not Sequential") #<%REMOVE%>
       NewDiagnosticRecord ($RulesMsg.E_PsnPositionsAreNotSequential -f $FunctionName,$PSN,"$SortedPositions") Error $Ast
     }  
   }
  }
}#TestSequentialAndBeginByZeroOrOne

Function Measure-DetectingErrorsInParameterList{         
<#
.SYNOPSIS
   Determines if the  parameters of a command are valid.

.EXAMPLE
   Measure-DetectingErrorsInParameterList $FunctionDefinitionAst
    
.INPUTS
  [System.Management.Automation.Language.FunctionDefinitionAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
   
.NOTES
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
      #régle 8 :TODO l'attribut [Parameter[position=0)] nécessite l'attribut [CmdletBinding()]
   try
   {          
    $Result_DEIPL=New-object System.Collections.Arraylist
    $FunctionName=$FunctionDefinitionAst.Name
    $DebugLogger.PSDebug("$('-'*40)") #<%REMOVE%>
    $DebugLogger.PSDebug("DetectingErrorsInParameterList : '$FunctionName'") #<%REMOVE%> 
    
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
    
    $ParametersList = GetParameter $ParamBlock $Result_DEIPL
    $script:isSharedParameterSetName_Unique=$false
     #régle 0 : si un paramétre déclare une position, les autres peuvent ne pas en déclarer
     #peut sembler incohérent ou incommode mais possible.
    
    #Une fois la liste construite on connait tous les psn
    #Pour celui nommé '__AllParametersSet' on doit ajouter tous ces paramètres à tous les autres PSN
    $Groups=$ParametersList.Values|Group-Object -Property PSN
   
     #On veut savoir s'il n'existe que le  jeu de paramètre par défaut.
    $script:isSharedParameterSetName_Unique=($Groups.Values.Count -eq 1) -and ($Groups[0].Name -eq $script:SharedParameterSetName)
   
    $OthersGroups=New-object System.Collections.Arraylist
    $DefaultGroup=Foreach ($group in $Groups) {
     if ($group.name -eq $script:SharedParameterSetName)
     {$group}
     else
     {$OthersGroups.Add($group) > $null}
    }
    
    if ($null -ne $DefaultGroup)
    {
      Foreach ($group in $OthersGroups)
      {
        $DebugLogger.PSDebug("Complete ParametersList") #<%REMOVE%>
        $psnName=$group.Name
        Foreach ($parameter in $DefaultGroup.Group)
        {  
          $DebugLogger.PSDebug("Add group $psnname $parameter") #<%REMOVE%>   
          $key="$($parameter.Name)$psnName"
          If (-not ($ParametersList.contains($Key)))
          {
            $ParametersList.Add($Key,(
              [pscustomObject]@{
                Name=$parameter.Name
                PSN=$psnName
                Position=$parameter.Position
              }))
          }
          else { $DebugLogger.PSDebug("Clé existant : $Key") } #<%REMOVE%>   
        }               
      }
    }
     
    Foreach ($GroupByPSN in ( $ParametersList.Values|Group-Object -Property PSN)) {
     $PSN=$GroupByPSN.Name
     $DebugLogger.PSDebug("Psn=$Psn") #<%REMOVE%>
   
     $isduplicate=$false
     #Pour chaque jeu, contrôle  les positions de ses paramètres
     # on regroupe une seconde fois pour déterminer s'il y a des duplications
     # et connaitre le nom des paramètres concernés.
     $GroupByPSN.Group|
      Group-Object Position|
       Foreach-Object {
        $ParameterName=$_.Group[0].Name   
        $DebugLogger.PSDebug("Parameter=$ParameterName") #<%REMOVE%>
         
        $Position=$_.Name -as [Int]
        if ($Position -ne $script:PositionDefault) 
        {
          # régle 2 : le nombre indiqué dans la propriété 'Position' doit être positif
         if ($Position -lt 0)
         {  
           $DebugLogger.PSDebug("`tRule : Position must be positive  '$PSN' - '$ParameterName' - $Position") #<%REMOVE%>
           $Result_DEIPL.Add((NewDiagnosticRecord ($RulesMsg.E_PsnMustHavePositivePosition -f $FunctionName,$PSN,$ParameterName,$Position) Error $FunctionDefinitionAst)) > $null
         }
        } 
        $_      
       }|
       Where-Object { ($_.Count -gt 1) -and ($_.Name[0] -ne '-')}|
       Foreach-Object{
        #Régle  3 : Les positions des paramètres d'un même jeu ne doivent pas être dupliqués
        #Ex 1,2,3 est correct, mais pas 1,2,3,1           
        $DebugLogger.PSDebug("`tRule : Duplicate position") #<%REMOVE%>
        $ofs=','
        $Result_DEIPL.Add((NewDiagnosticRecord ($RulesMsg.E_PsnDuplicatePosition -F $FunctionName,$PSN,$_.Name,"$($_.group.name)") Error $FunctionDefinitionAst)) > $null
        $isDuplicate=$true
       }

     $Dr=@(TestSequentialAndBeginByZeroOrOne $FunctionName $GroupByPSN $FunctionDefinitionAst $isDuplicate)
     $Result_DEIPL.AddRange($Dr)> $null

    } #foreach

    if ($Result_DEIPL.count -gt 0)
    {
      $DebugLogger.PSDebug("return Result") #<%REMOVE%>
      return $Result_DEIPL 
    }
   }
   catch
   {
      $ER= New-Object -Typename System.Management.Automation.ErrorRecord -Argumentlist $_.Exception, 
                                                                             "DetectingErrorsInParameterList-$FunctionName", 
                                                                             "NotSpecified",
                                                                             $FunctionDefinitionAst
      $DebugLogger.PSFatal($_.Exception.Message,$_.Exception) #<%REMOVE%>
      $PSCmdlet.ThrowTerminatingError($ER) 
   }       
  }#process
}#Measure-DetectingErrorsInParameterList

#todo
Function Measure-DetectingErrorsInOutputAttribut{         
<#
.SYNOPSIS
  todo

.EXAMPLE
   Measure-DetectingErrorsInOutputAttribut $FunctionDefinitionAst
    
.INPUTS
  [System.Management.Automation.Language.FunctionDefinitionAst]
  
.OUTPUTS
   [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
   
.NOTES
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
   try
   {     

    <#
    Pour un attribut:
      s'il existe des valeurs de type chaîne Et que parametersetname n'est pas renseigné
       alors afficher warning "vérifiez si PSN est nécessaire""
      
      s'il existe parametersetname vérifier que le nom existe bien dans la liste de tous les PSN
      sinon erreur.
      
      s'il existe plusieurs déclarations , chacun doit préciser un PSN 
      sinon afficher Info "Précisez un PSN est recommander""
       
    #>     
    Write-Warning "En construction."
    $Result_DEIOPA=New-object System.Collections.Arraylist
    $FunctionName=$FunctionDefinitionAst.Name
    $DebugLogger.PSDebug("$('-'*40)") #<%REMOVE%>
    $DebugLogger.PSDebug("DetectingErrorsInOutPutAttribut : '$FunctionName'") #<%REMOVE%> 
    
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
    
      $DebugLogger.PSDebug("end process") #<%REMOVE%>
    if ($Result_DEIOPA.count -gt 0)
    {
      $DebugLogger.PSDebug("return Result") #<%REMOVE%>
      return $Result_DEIOPA 
    }
   }
   catch
   {
      $ER= New-Object -Typename System.Management.Automation.ErrorRecord -Argumentlist $_.Exception, 
                                                                             "DetectingErrorsInParameterList-$FunctionName", 
                                                                             "NotSpecified",
                                                                             $FunctionDefinitionAst
      $DebugLogger.PSFatal($_.Exception.Message,$_.Exception) #<%REMOVE%>
      $PSCmdlet.ThrowTerminatingError($ER) 
   }       
  }#process
}#Measure-DetectingErrorsInOutputAttribut

#<DEFINE %DEBUG%> 
Function OnRemoveParameterSetRules {
  Stop-Log4Net $Script:lg4n_ModuleName
}#OnRemoveParameterSetRules
 
# Section  Initialization
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveParameterSetRules }
#<UNDEF %DEBUG%>   
 
Export-ModuleMember -Function Measure-DetectingErrorsInDefaultParameterSetName,
                              Measure-DetectingErrorsInParameterList,
                              New-TestSetParameter