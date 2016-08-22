Function TestParameterSet{
  [CmdletBinding(defaultparameterSetName = "F3")]
  Param (
    [Parameter()]
   [Switch] $A,
   
    [Parameter(Mandatory)]
   [Switch] $B,
   
    [Parameter(Position=1,parameterSetName="F3")]
   [Switch] $C,
   
    $D
   )
  Write-Host "Traitement..."
}