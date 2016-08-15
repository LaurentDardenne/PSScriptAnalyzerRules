#<%ScriptAnalyzer categories%>. Tag : PSScriptAnalyzer, PSScriptAnalyzerRule, Analyze, Rule

Import-LocalizedData -BindingVariable Log4PoshMsgs -Filename Log4Posh.Resources.psd1 -EA Stop

$Script:lg4n_ModuleName=$MyInvocation.MyCommand.ScriptBlock.Module.Name

   #Récupère le code d'une fonction publique du module Log4Posh (Prérequis)
   #et l'exécute dans la portée du module
$InitializeLogging=$MyInvocation.MyCommand.ScriptBlock.Module.NewBoundScriptBlock(${function:Initialize-Log4NetModule})
&$InitializeLogging $Script:lg4n_ModuleName "$psScriptRoot\ParameterSetRulesLog4Posh.Config.xml"

$script:Helpers=[Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper]::new($MyInvocation.MyCommand.ScriptBlock.Module.SessionState.InvokeCommand,$null)

function Get-CommonParameters{ 
  # Common parameters
  #  -Verbose (vb) -Debug (db) -WarningAction (wa)
  #  -WarningVariable (wv) -ErrorAction (ea) -ErrorVariable (ev)
  #  -OutVariable (ov) -OutBuffer (ob) -WhatIf (wi) -Confirm (cf)
  #  -InformationAction (infa) InformationAction (iv) PipelineVariable (pv) #PS v4 et v5

 [System.Management.Automation.Internal.CommonParameters].GetProperties().Names
}#Get-CommonParameters
[string[]]$script:CommonParameters=Get-CommonParameters

$script:CommonParametersFilter= { $script:CommonParameters -notContains $_.Name}

#todo
$script:Helpers=[Microsoft.Windows.PowerShell.ScriptAnalyzer.Helper]::new($MyInvocation.MyCommand.ScriptBlock.Module.SessionState.InvokeCommand,$null)

function Get-CommonParameters{ 
 [System.Management.Automation.Internal.CommonParameters].GetProperties().Name
}#Get-CommonParameters

[string[]]$script:CommonParameters=Get-CommonParameters
$script:CommonParametersFilter= { $script:CommonParameters -notContains $_.Name}

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

  #$isDefaultParameterSetNameValid
       #False si l'attribut CmdletBinding est déclaré et que le DefaultParameterSetName n'existe pas dans les jeux déclarés.  
       #True si aucun attribut CmdletBinding n'est pas déclaré ou s'il est le seul à déclarer un nom de jeu,
       #True si l'attribut CmdletBinding est déclaré et qu'il existe un seul jeu de même nom, 
       #Trues si l'attribut CmdletBinding est déclaré et qu'il existe dans les jeux déclarés
       #True par défaut

process { 
# #todo
# Test-OutputTypeAttibut
# s'il en existe: le nom du jeu doit exister, ne pas être dupliqué ?

  Write-Debug "Control $($FunctionDefinitionAst.Name)" #Todo Log4Posh
  $isDefaultParameterSetNameValid=$true

  try
  {
    $Result=New-object System.Collections.Arraylist
    $ParamBlock=$FunctionDefinitionAst.Body.ParamBlock
    
    $CBA=$script:Helpers.GetCmdletBindingAttributeAst($ParamBlock.Attributes)
    $CBAExtent=$CBA.Extent
    $DPS=$CBA.NamedArguments.Where({$_.ArgumentName -eq 'DefaultParameterSetName'}).Argument.Value
      #Récupère les noms de jeux 
      #Les paramètres communs sont dans le jeu nommé '__AllParameterSets'
    [string[]] $ParameterSets=$ParamBlock.Parameters.Attributes.NamedArguments.Where({$_.ArgumentName -eq 'ParameterSetName'}).Argument.Value|
                    Select-Object -Unique
    $SetCount=$ParameterSets.Count
  
    Write-Debug "DefaultParameterSet est-il renseigné ? $($null -ne $DPS)"
    Write-Debug "Dps= $DPS"    
    Write-Debug "Nombre de jeux de paramètre : $SetCount"
    
    if ($null -ne $DPS) #todo tests
    {
       if ($SetCount -gt 1) #todo case insensitive ?
       {
         if ( $DPS -eq '__AllParameterSets') #Nommage improbable, mais autorisé
         { 
           Write-Debug "Test sur __AllParameterSets" 
           $isDefaultParameterSetNameValid= $DPS -ceq '__AllParameterSets'
           if ($isDefaultParameterSetNameValid -eq $false)
           {
               #todo Le nom du jeu par défaut n'est pas unique (cas de casse différente) dans la liste des noms de jeux
             $Correction=New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent" `
                         -ArgumentList  $CBAExtent.StartLineNumber,
                                        $CBAExtent.EndLineNumber,
                                        $CBAExtent.StartColumnNumber,
                                        $CBAExtent.EndColumnNumber,
                                        $FunctionDefinitionAst.Name,
                                        $FunctionDefinitionAst.Extent.File,                
                                        "Avoid to use '__AllParameterSets' as name of a parameter set."
             
             #DiagnosticRecord(string message, IScriptExtent extent, string ruleName, DiagnosticSeverity severity, 
             #                 string scriptPath, string ruleId = null, List<CorrectionExtent> suggestedCorrections = null)
             $result.Add((New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
                         -ArgumentList 'DPS CaseSensitiveDetected',$FunctionDefinitionAst.Extent,$PSCmdlet.MyInvocation.InvocationName,Error,$null,$null,@($Correction))) >$null
           }
         }
         
         Write-Debug "Test sur les jeux de paramètre: $ParameterSets"
         if ($DPS -cnotin $ParameterSets)
         {
           Write-Debug "Dps inutilisé"
           $Correction=New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.CorrectionExtent" `
            -ArgumentList  $CBAExtent.StartLineNumber,
                           $CBAExtent.EndLineNumber,
                           $CBAExtent.StartColumnNumber,
                           $CBAExtent.EndColumnNumber,
                           $FunctionDefinitionAst.Name,
                           $FunctionDefinitionAst.Extent.File,                
                           'DefaultParameterSetName is not used.'
           $result.Add((New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
                       -ArgumentList 'DPS inutilisé',$FunctionDefinitionAst.Extent,$PSCmdlet.MyInvocation.InvocationName,Error,$null)) >$null
         }
          #bug https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11088147-parameterset-names-should-not-be-case-sensitive
          # Si DPS à la même casse on utilise le même jeu (nom identique), sinon PS en crée deux
         
         $ParameterSets += $DPS
         $CaseSensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCulture)
         $CaseInsensitive=[System.Collections.Generic.HashSet[String]]::new($ParameterSets,[StringComparer]::InvariantCultureIgnoreCase)
          if ($CaseSensitive.Count -ne $CaseInsensitive.Count)
         {
           Write-Debug "paramset en double "
           $result.Add((New-Object -Typename "Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord" `
                       -ArgumentList 'Jeux CaseSensitiveDetected',$FunctionDefinitionAst.Extent,$PSCmdlet.MyInvocation.InvocationName,Error,$null)) > $null
         }  
         Write-Debug "isDefaultParameterSetNameValid=$isDefaultParameterSetNameValid"
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

#todo à adapter
Function Test-ParameterSet{
<#
.SYNOPSIS
   Détermine si les jeux de paramètres d'une commande sont valides.
   Un jeux de paramètres valide doit contenir au moins un paramètre unique et
   les numéros de positions de ses paramètres doivent se suivre et ne pas être dupliqué.
   Les noms de paramètres débutant par un chiffre invalideront le test.
#>  
 param (
   #Nom de la commande à tester
  [parameter(Mandatory=$True,ValueFromPipeline=$True)]
  [string]$Command  #todo CommandInfo ET CommandName
 ) 
begin {
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
}#end

process {
  $Cmd=Get-Command $Command
  Write-Debug "Test $Command"
  
     #bug PS : https://connect.microsoft.com/PowerShell/feedback/details/653708/function-the-metadata-for-a-function-are-not-returned-when-a-parameter-has-an-unknow-data-type
  $oldEAP,$ErrorActionPreference=$ErrorActionPreference,'Stop'
   $SetCount=$Cmd.get_ParameterSets().count
  $ErrorActionPreference=$oldEAP

  $_AllNames=@($Cmd.ParameterSets|
            Foreach {
              $PrmStName=$_.Name
              $P=$_.Parameters|Foreach {$_.Name}|Where  {$_ -notin $script:CommonParameters} 
              Write-Debug "Build $PrmStName $($P.Count)"
              if (($P.Count) -eq 0)
              { Write-Warning "[$($Cmd.Name)]: the parameter set '$PrmStName' is empty." }
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
     Write-Debug "Current ParemeterSet $Name"
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
        Write-debug "Add $ParameterName $($_.Position)"
        $Params.Add($ParameterName) > $null
        $Positions.Add($_.Position) > $null
         #Toutes les constructions ne sont pas testées
         #par exemple les noms d'opérateur, cela fonctionne mais rend le code légérement obscur
         #todo pas d'espace au début ou en fin
         #todo ${global:test}
         #todo ne pas contenir de point
        if (($ParameterName -match "^\d|-|\+|%|&" ) -or ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($ParameterName)))
        { 
          Write-debug "Invalide parameter name '$ParameterName'"
          $InvalidParametersName.Add($ParameterName) > $null 
        }         
      }
     
      #Supprime dans la collection globale
      #les noms de paramètres du jeux courant
     $Params| 
      Foreach { 
        Write-Debug "Remove $_"
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
           Write-Debug "Only one parameter set."
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

Function OnRemoveParameterSetRules {
  Stop-Log4Net $Script:lg4n_ModuleName
}#OnRemovePsIonicZip
 
# Section  Initialization
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { OnRemoveParameterSetRules }
 
Export-ModuleMember -Function Measure-DetectingErrorsInDefaultParameterSetName