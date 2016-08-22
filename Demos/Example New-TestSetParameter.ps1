#Démos de New-TestSetParameter

 #Récupère les métadonnées d'une commande
$cmd=Get-Command Test-Path
 #Déclare un variable portant le même nom que le paramètre qu'on souhaite
 #inclure dans le produit cartésien. 
 #Chaque valeur du tableau crée une ligne d'appel 
$Path=@(
  "'c:\temp\unknow.zip'",
  "'Test.zip'",
  "(dir variable:OutputEncoding)",
  "'A:\test.zip'",
  "(Get-Item 'c:\temp')",
  "(Get-Service Winmgmt)",
  'Wsman:\*.*',
  'hklm:\SYSTEM\CurrentControlSet\services\Winmgmt'
)

#Le paramètre 'PathType' est une énumération de type booléen
$PathType=@("'Container'", "'Leaf'")

#Génére les combinaisons du jeu de paramètre nommée 'Path'
#Les paramètres qui ne sont pas associés à une variable, génére un warning.
$result=New-TestSetParameter -command $Cmd  -ParameterSetNames Path

#Nombre de lignes construites
$result.lines.count

#Exécution, Test-path n'a pas d'impact sur le FileSystem
$result.lines|% {Write-host $_ -fore green;$_}|Invoke-Expression

#On ajoute le paramètre 'iSValide' de type booléen
$isValid= @($true,$false)

#Génére les combinaisons du jeu de paramètre nommée 'Path'
$result=New-TestSetParameter -command $Cmd  -ParameterSetNames Path -WarningAction 'SilentlyContinue'
#génère :
# Test-Path -Path 'c:\temp\unknow.zip' -PathType 'Container' -IsValid
# Test-Path -Path 'A:\test.zip' -PathType 'Container' -IsValid
# Test-Path -Path 'A:\test.zip' -PathType 'Leaf' -IsValid
# Test-Path -Path 'A:\test.zip' -PathType 'Container'
# Test-Path -Path 'A:\test.zip' -PathType 'Leaf'
# ...

$result.lines.count
#$Result.lines|Sort-Object|% {Write-host $_ -fore green;$_}|Invoke-Expression

#On peut aussi générer du code de test pour Pester ou un autre module de test :
$Template=@'
#
    It "Test ..TO DO.." {
        try{
          `$result = $_ -ea Stop
        }catch{
            Write-host "Error : `$(`$_.Exception.Message)" -ForegroundColor Yellow
             `$result=`$false
        }
        `$result | should be (`$true)
    }
'@
$Result.Lines| % { $ExecutionContext.InvokeCommand.ExpandString($Template) }
#génère :
#     It "Test ..TO DO.." {
#         try{
#           $result = Test-Path -Path 'c:\temp\unknow.zip' -PathType 'Container' -IsValid -ea Stop
#         }catch{
#             Write-host "Error : $($_.Exception.Message)" -ForegroundColor Yellow
#              $result=$false
#         }
#         $result | should be ($true)
#     }
