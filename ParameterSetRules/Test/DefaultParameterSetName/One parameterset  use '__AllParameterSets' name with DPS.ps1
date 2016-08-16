Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "Fonctionnalite3")]
  Param (
    [Parameter(ParameterSetName="__AllParameterSets")]
   [Switch] $A,
    [Parameter(ParameterSetName="Fonctionnalite2")]
   [Switch] $B,
    [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $C,
    [Parameter(ParameterSetName="__AllParameterSets")]
    [Parameter(ParameterSetName="Fonctionnalite2")]
    [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $D,
    [Parameter(ParameterSetName="Fonctionnalite2")]
   [Switch] $E

   )
  Write-Host "Traitement..."
}
