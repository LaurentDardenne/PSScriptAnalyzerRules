#<%ScriptAnalyzer categories%>. Tag : PSScriptAnalyzer, PSScriptAnalyzerRule, Analyze, Rule
#guideline : Gotchas, Refactoring, PSIssue/PSBehavior

Import-LocalizedData -BindingVariable RulesMsg -Filename ParameterSetRules.Resources.psd1 -EA Stop
                                      
#Todo Test-OutputTypeAttribut -> ParameterSetName inused or case sensitive
#Todo doc functions
#todo 
# Code du module PS v3, code source pour PS version 2, régle différente: exemple celle de gestion des PSN 

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

function Get-CommonParameter{ 
  [System.Management.Automation.Internal.CommonParameters].GetProperties().Names
}#Get-CommonParameter

[string[]]$script:CommonParameters=Get-CommonParameter

$script:CommonParametersFilter= { $script:CommonParameters -notContains $_.Name}


$script:PositionDefault=[int]::MinValue
$script:SharedParameterSetName='by default' #__AllParametersSet' #or .IsInAllSets ?
$script:isSharedParameterSetName_Unique=$false

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
  param($ParamBlock)
   #todo déclaration [Parameter()] inutile

   #Un jeu de paramètres ne peut être déduit de la position
   #si aucun de ses paramètres n'est mandatory
   #BUG PS: 
   # une duplication de déclaration identique invalide le résultat de Get-Commande :
   #   
   #   [Parameter(Position=1,parameterSetName="Fonctionnalite3")]
   #   [Parameter(Position=1,parameterSetName="Fonctionnalite3")]
   #    [Switch] $C,
   #
   # Il reste possbile de déclarer ainsi
   #   [Parameter(Position=1)]
   #   [Parameter(parameterSetName="Fonctionnalite3")]
   #    [Switch] $C,
  

  $DebugLogger.PSDebug("ParamBlock.Parameters.Count: $($ParamBlock.Parameters.Count)") #<%REMOVE%>
  Foreach ($Parameter in $ParamBlock.Parameters)
  {
   $ParameterName=$Parameter.Name.VariablePath.UserPath
   $PSN=$script:SharedParameterSetName
   $Position=$script:PositionDefault
   
   foreach ($Attribute in $Parameter.Attributes)
   {
       if ($Attribute.TypeName.FullName -ne 'Parameter')
       { continue }
       if (($null -eq $Attribute.NamedArguments) -and ($null -eq $Attribute.PositionalArguments))
       {
         #régle 7: Un attribut [Parameter()] vide est inutile
         $DebugLogger.PSDebug("`tRule : [Parameter()] vide") #<%REMOVE%>
         $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : The parameter  '$ParameterName' declare an unnecessary ParameterAttribut." Error )) > $null
       }
       foreach ($NamedArgument in $Attribute.NamedArguments)
       {
          $ArgumentName=$NamedArgument.ArgumentName
          if ($ArgumentName -eq 'ParameterSetName')
          { $PSN=$NamedArgument.Argument.Value }
          elseif ($ArgumentName -eq 'Position')
          { $Position=$NamedArgument.Argument.Value}
       }
      $DebugLogger.PSDebug("Add '$ParameterName' into '$psn'") #<%REMOVE%>
      [pscustomObject]@{
       Name=$ParameterName
       PSN=$psn
       Position=$Position
      }
   }
  }  
}#GetParameter    


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
   [PSObject]
   
.NOTES
  None
  
#>
function New-TestSetParameter{
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","",
                                                     Justification="New-TestSetParameter do not change the system state, only the application 'context'")]
#Génére le produit cartésien de chaque jeux de paramètre d'une commande (tools for Pester)
#adapted from : #http://makeyourownmistakes.wordpress.com/2012/04/17/simple-n-ary-product-generic-cartesian-product-in-powershell-20/
 [CmdletBinding()]
 [OutputType([system.string])]
 param (
   [parameter(Mandatory=$True,ValueFromPipeline=$True)]
   [ValidateNotNull()]
  [System.Management.Automation.CommandInfo] $CommandName,
    
    [ValidateNotNullOrEmpty()]
    [Parameter(Position=0,Mandatory=$false)]
  [string[]] $ParameterSetNames='__AllParameterSets',
    
    [ValidateNotNullOrEmpty()]
  [string[]] $Exclude,
  
  [switch] $All
 )       

 begin {
  function getValue{
     if ($Value -eq $false)
     {
       Write-Debug "Switch is `$false, dont add the parameter name : $Result."
       return "$result"
     }
     else
     {
       Write-Debug "Switch is `$true, add only the parameter name : $result$Bindparam"
       return "$result$Bindparam"
     }
  }#getValue
  
  function AddToAll{
   param (
     [System.Management.Automation.CommandParameterInfo] $Parameter,
     $currentResult, 
     $valuesToAdd
   )
    Write-Debug "Treate '$($Parameter.Name)' parameter."
    Write-Debug "currentResult =$($currentResult.Count -eq 0)"
    $Bindparam=" -$($Parameter.Name)" 
      #Récupère une information du type du paramètre et pas la valeur liée au paramètre
    $isSwitch=($Parameter.parameterType.FullName -eq 'System.Management.Automation.SwitchParameter')
    Write-Debug "isSwitch=$isSwitch"
    $returnValue = @()
    if ($null -ne $valuesToAdd)
    {
      foreach ($value in $valuesToAdd)
      {
        Write-Debug "Add Value : $value "
        if ($Null -ne $currentResult)
        {
          foreach ($result in $currentResult)
          {
            if ($isSwitch) 
            { $returnValue +=getValue } 
            else
            {
              Write-Debug "Add parameter and value : $result$Bindparam $value"
              $returnValue += "$result$Bindparam $value"
            }
          }#foreach
        }
        else
        {
           if ($isSwitch) 
           { $returnValue +="$($CommandName.Name)$(getValue)" } 
           else 
           {
             Write-Debug "Add parameter and value :: $Bindparam $value"
             $returnValue += "$($CommandName.Name)$Bindparam $value"
           }
        }
      }
    }
    else
    {
      Write-Debug "ValueToAdd is `$Null :$currentResult"
      $returnValue = $currentResult
    }
    return $returnValue
  }#AddToAll  
 }#begin

  process {
          
   foreach ($Set in $CommandName.ParameterSets)
   {
      if (-not $All -and ($ParameterSetNames -notcontains $Set.Name)) 
      { continue }
      elseif ( $All -and ($Exclude -contains $Set.Name)) 
      {
        Write-Debug "Exclude $($Set.Name) "
        continue
      }
      
      $returnValue = @()
      Write-Debug "Current set name is $($Set.Name) "
      Write-Debug "Parameter count=$($Set.Parameters.Count) "
      #Write-Debug "$($Set.Parameters|Select name|out-string) "
      foreach ($parameter in $Set.Parameters)
      {
         #Api V4 et >
        $Values= $MyInvocation.MyCommand.Module.GetVariableFromCallersModule($Parameter.Name) #todo -ea SilentlyContinue
        if ( $null -ne $Values) 
        { $returnValue = AddToAll -Parameter $Parameter $returnValue $Values.Value }
        else
        { $PSCmdlet.WriteWarning("The variable $($Parameter.Name) is not defined, processing the next parameter.") } 
      }
     New-Object PSObject -Property @{PSTypeName='CartesianProductOfParameters';CommandName=$CommandName.Name;SetName=$Set.Name;Lines=$returnValue.Clone()}
   }#foreach
  }#process
} #New-TestSetParameter


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
    $Result_DEIDPSN=New-object System.Collections.Arraylist 
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
    $DebugLogger.PSDebug("ParamBlock.Attributes.Count: $($ParamBlock.Attributes.Count)") #<%REMOVE%>
    
      #note: si plusieurs attributs [CmdletBinding] existe, la méthode CmdletBinding() renvoi le premier trouvé 
    $CBA=$script:Helpers.GetCmdletBindingAttributeAst($ParamBlock.Attributes)
    $DPS_Name=($CBA.NamedArguments|Where-Object {$_.ArgumentName -eq 'DefaultParameterSetName'}).Argument.Value
  
      #Récupère les noms de jeux 
      #Les paramètres communs sont dans le jeu nommé '__AllParameterSets' créé à l'exécution
    [string[]] $ParameterSets=@(($ParamBlock.Parameters.Attributes.NamedArguments|Where-Object {$_.ArgumentName -eq 'ParameterSetName'}).Argument.Value|
                    Select-Object -Unique)
    $SetCount=$ParameterSets.Count
  
    $DebugLogger.PSDebug("DefaultParameterSet is set ? $($null -ne $DPS_Name)") #<%REMOVE%>
    $DebugLogger.PSDebug("DefaultParameterSet name= $DPS_Name") #<%REMOVE%>    
    $DebugLogger.PSDebug("Number of parameter set : $SetCount") #<%REMOVE%>
     $DebugLogger.PSDebug("parameter set : $ParameterSets") #<%REMOVE%>
    
    if (($null -eq $DPS_Name) -and ($SetCount -eq 0 ))
    { return } #Nothing to do                                                                           
    
    if (($null -eq $DPS_Name) -and ($SetCount -gt 1))
    {  
       #Todo : Pour certaines constructions basées sur les paramètres obligatoire (ex: Pester.Set-ScriptBlockScope) #<%REMOVE%>
       #       ce warning ne devrait pas se déclencher.                                                             #<%REMOVE%>
      $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.W_DpsNotDeclared -F $FunctionName) Warning)) > $null 
    } 

    # Les cas I_PsnRedundant et I_DpsUnnecessary sont similaires                                                      
    # Pour I_PsnRedundant il y a 1,n déclarations redondantes mais pour I_DpsUnnecessary il y a 1 déclaration inutile
    if ((($null -ne $DPS_Name) -and ($SetCount -eq 1) -and ($DPS_Name -ceq  $ParameterSets[0])) -or (($null -eq $DPS_Name) -and ($SetCount -eq 1))) 
    {       
       $DebugLogger.PSDebug("PSN redondant.") #<%REMOVE%>
       $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.I_PsnRedundant -F $FunctionName) Information )) > $null
    }
    
    if (@($ParameterSets;$DPS_Name) -eq [System.Management.Automation.ParameterAttribute]::AllParameterSets)
    { 
       $DebugLogger.PSDebug("Le nom est '__AllParameterSets', ce nommage est improbable, mais autorisé") #<%REMOVE%>
       $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.W_DpsAvoid_AllParameterSets_Name -F $FunctionName) Warning )) > $null
    }

    if ($null -ne $DPS_Name) 
    {       
       if (($SetCount -eq  0) -or (($SetCount -eq  1) -and ($DPS_Name -ceq  $ParameterSets[0])))
       {
          $DebugLogger.PSDebug("Dps seul est inutile") #<%REMOVE%>
          $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.I_DpsUnnecessary -F $FunctionName) Information )) > $null
       }
       else 
       {       
          $DebugLogger.PSDebug("Test sur la cohérence et sur la casse: $ParameterSets") #<%REMOVE%>
          if (($ParameterSets.count -gt 0) -and ($DPS_Name -cnotin $ParameterSets))
          {
            $DebugLogger.PSDebug("Dps inutilisé") #<%REMOVE%>
            $Result_DEIDPSN.Add((NewDiagnosticRecord ($RulesMsg.E_DpsInused -F $FunctionName) Error)) > $null
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
         $Result_DEIDPSN.Add((New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
                     -ArgumentList ($RulesMsg.E_CheckPsnCaseSensitive -F $FunctionName,"$($ParameterSets -eq ($CaseSensitive|Select-Object -first 1))"),
                                   $FunctionDefinitionAst.Extent,$PSCmdlet.MyInvocation.InvocationName,Error,$null,$null,$Correction)) > $null
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
     $PSCmdlet.ThrowTerminatingError($ER) 
  }       
 }#process
}#Measure-DetectingErrorsInDefaultParameterSetName

function TestParameterName{
 #caution : use the parent scope (Measure-DetectingErrorsInParameterList)         
 
  #Toutes les constructions ne sont pas testées
  # par exemple les noms d'opérateur, cela fonctionne mais rend le code légérement obscur
  #todo espaces dans le nom
  #todo scope ${global:test} ${env:Temp} ${c:\get-noun}
  # todo $isSafeNameOrIdentifierRegex = @"^[-._:\\\p{Ll}\p{Lu}\p{Lt}\p{Lo}\p{Nd}\p{Lm}]{1,100}$","Singleline,CultureInvariant"
  if ($ParameterName -match "(?<Number>^\d)|(?<Operator>-|\+|%|&)|(?<Dot>\.)|(?<Space>^\s+|\s+$)|(?<PSWildcard>\*|\?\[\])")
  { 
    $Message="The parameter name '$ParameterName' is invalid because it contains a invalid character : "
    if ($matches.Contains('Number'))
    { $reason= "it must not have begun by numbers." }
    elseif ($matches.Contains('Dot'))
    { $reason= "it must not contains a dot character." }
    elseif ($matches.Contains('Operator'))
    { $reason= "it must not contains a operator token." }
    elseif ($matches.Contains('Space'))
    { $reason= "it must not have begun or endung by spaces." }
    elseif ($matches.Contains('PSWildCard'))
    { $reason= "it must not contains Powershell wildcard." }
    
     #Régle 6 : Le nom d'un paramètre doit éviter certains caractères
    $DebugLogger.PSDebug("`tRule : Invalide parameter Name") #<%REMOVE%>
    #$Result_DEIPL.Add((NewDiagnosticRecord ($RulesMsg.W_DpsAvoid_AllParameterSets_Name -F $FunctionName) Warning )) > $null
    $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : $Message $Reason" Error )) > $null
 }         
}#TestParameterName


function TestSequentialAndBeginByZeroOrOne{
 #caution : use the parent scope (Measure-DetectingErrorsInParameterList)  
 
  $SortedPositions=$GroupByPSN.Group.Position -ne $script:PositionDefault|Sort-Object 
  if ($null -ne $SortedPositions)
  {
    #Régle  4 : Les positions doivent débuter à zéro ou 1
    #Il reste possible d'utiliser des numéros de position arbitraire mais au détriment de la compréhension/relecture
    #un jeu (J1) peut avoir un paramètre ayant une position 2, dans le cas où un paramètre commun (J0) à tous
    #les jeux indique une position 1, la régle sera validé J1=(J1+J0). 
    #Mais si c'est le jeu par défaut on ne peut pas raisonnablement connaitre l'exactitude des positions
    #Sauf si le jeu par défaut est le seul déclarer. 
   if (($SortedPositions[0] -gt 1) -and ($script:isSharedParameterSetName_Unique -and ($GroupByPSN.Name -ne $script:SharedParameterSetName))) 
   { 
     $DebugLogger.PSDebug("`tRule : The positions of parameters must begin by zero or one -> $($SortedPositions[0])") #<%REMOVE%>
     $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : '$PSN' The positions of parameters must begin by zero or one: $SortedPositions" Error )) > $null
   }
   if (-not $iDusplicate) 
   {
     #régle 5 : L'ensemble des positions doit être une suite ordonnée d'éléments.
     # Ex 1,2,3 est correct, mais pas 1,3 ou 1,2,3,1
     # Des positions de paramètre dupliqués invalident forcément cette régle 5   
     if (-not (TestSequential $SortedPositions))
     { 
       $DebugLogger.PSDebug("`tRule : Not Sequential") #<%REMOVE%>
       $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : The ParameterSet '$PSN' contains positions which are not sequential: $SortedPositions" Error )) > $null
     }  
   }
  }
}#TestSequentialAndBeginByZeroOrOne

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
   try {         
    $Result_DEIPL=New-object System.Collections.Arraylist
    $FunctionName=$FunctionDefinitionAst.Name
    $DebugLogger.PSDebug("$('-'*40)") #<%REMOVE%>
    $DebugLogger.PSDebug("DetectingErrorsInParameterList : '$FunctionName'") #<%REMOVE%> 
    
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    $DebugLogger.PSDebug("Paramblock is null : $($null -eq $ParamBlock)") #<%REMOVE%>
    if ($null -eq $ParamBlock)
    { return } 
   
    $ParametersList=New-object System.Collections.Arraylist
    $ParametersList.AddRange(@(GetParameter $ParamBlock))
    $script:isSharedParameterSetName_Unique=$false
     #régle 0 : si un paramétre déclare une position, les autres peuvent ne pas en déclarer
     #peut sembler incohérent ou incommode mais possible.
    
    #Une fois la liste construite on connait tous les psn
    #Pour celui nommé 'By défault' on doit ajouter tous ces paramètres à tous les autres PSN
    $Groups=$ParametersList|Group-Object -Property PSN
    $script:isSharedParameterSetName_Unique=($Groups.Count -eq 1) -and ($Groups[0].Name -eq $script:isSharedParameterSetName)
    $OthersGroups=New-object System.Collections.Arraylist
    $DefaultGroup=Foreach ($group in $Groups) {
     if ($group.name -eq $script:SharedParameterSetName)
     {$group}
     else
     {$OthersGroups.Add($group) > $null}
    }
    $DebugLogger.PSDebug("Complete ParametersList") #<%REMOVE%>
    if ($null -ne $DefaultGroup)
    {
      Foreach ($group in $OthersGroups)
      {
        $psnName=$group.Name
        Foreach ($parameter in $DefaultGroup.Group)
        {  
          $DebugLogger.PSDebug("add $psnname $parameter") #<%REMOVE%>   
          $ParametersList.Add((
            [pscustomObject]@{
               Name=$parameter.Name
               PSN=$psnName
               Position=$parameter.Position
            })) > $null
       }               
     }
   }
      
    Foreach ($GroupByPSN in ( $ParametersList|Group-Object -Property PSN)) {
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
         
         #régle 1 : un nom de paramètre ne doit pas commencer par un chiffre,
         # ni contenir certains caractères. Ceci pour les noms de paramètre ${+Name.Next*}
        TestParameterName
             
        $Position=$_.Name -as [Int]
        if ($Position -ne $script:PositionDefault) 
        {
          # régle 2 : le nombre indiqué dans la propriété 'Position' doit être positif
         if ($Position -lt 0)
         {  
           $DebugLogger.PSDebug("`tRule : Position must be positive  '$PSN' - '$ParameterName' - $Position") #<%REMOVE%>
           $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : In the ParameterSet '$PSN', the parameter '$ParameterName' must have a positive position ($Position)" Error )) > $null
         }
        } 
        $_      
       }|
       Where-Object { ($_.Count -gt 1) -and ($_.Name[0] -ne '-')}|
       Foreach-Object{
        #Régle  3 : Les positions des paramètres d'un même jeu ne doivent pas être dupliqués
        #Ex 1,2,3 est correct, mais pas 1,2,3,1           
        $DebugLogger.PSDebug("`tRule : Duplicate position") #<%REMOVE%>
        $Result_DEIPL.Add((NewDiagnosticRecord "$FunctionName : The ParameterSet '$PSN' contains duplicate position $($_.Name) for $($_.group.name)" Error )) > $null
        $isDuplicate=$true
       }

     TestSequentialAndBeginByZeroOrOne

    } #foreach
    $DebugLogger.PSDebug("end process") #<%REMOVE%>
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
      $PSCmdlet.ThrowTerminatingError($ER) 
   }       
  }#process
}#Measure-DetectingErrorsInParameterList

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