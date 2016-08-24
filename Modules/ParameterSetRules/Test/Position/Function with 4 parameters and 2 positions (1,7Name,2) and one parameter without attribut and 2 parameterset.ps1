Function TestParameterSet{
  Param (
    [Parameter(Position=1,ParameterSetName="Fonctionnalite1")]
   [string] $A,
   
   [string] $7Name,
   
    [Parameter(Position=2,ParameterSetName="Fonctionnalite1")]
    [Parameter(Position=2,ParameterSetName="Fonctionnalite2")]
   
   [string] $C,
   
   $D
   )
  Write-Host "Test"
}
