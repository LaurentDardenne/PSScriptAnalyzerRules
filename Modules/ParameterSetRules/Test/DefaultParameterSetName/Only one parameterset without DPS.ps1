Function TestParameterSet{
  Param (
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A,
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $B
   )
  Write-Host "Traitement..."
}
