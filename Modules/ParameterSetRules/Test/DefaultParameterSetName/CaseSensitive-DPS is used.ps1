Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "Fonctionnalite3")]
  Param (
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A,
    [Parameter(ParameterSetName="Fonctionnalite2")]
   [Switch] $B,
    [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $C,
    [Parameter(ParameterSetName="Fonctionnalite1")]
    [Parameter(ParameterSetName="Fonctionnalite2")]
    [Parameter(ParameterSetName="Fonctionnalite3")]
   [Switch] $D,
    [Parameter(ParameterSetName="fonctionnalite2")]
   [Switch] $E

   )
  Write-Host "Traitement..."
}
