Function TestParameterSet{
  [CmdletBinding(defaultparameterSetName = "Fonctionnalite3")]
  Param (
    [Parameter(ParametersetName="__AllParameterSets")]
   [Switch] $A,
    [Parameter(ParameterSetname="Fonctionnalite2")]
   [Switch] $B,
    [Parameter(parameterSetName="Fonctionnalite3")]
   [Switch] $C,
    [Parameter(parametersetname="__AllParameterSets")]
    [Parameter(ParameterSetName="Fonctionnalite2")]
    [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $D,
    [Parameter(ParameterSetName="Fonctionnalite2")]
   [Switch] $E

   )
  Write-Host "Traitement..."
}