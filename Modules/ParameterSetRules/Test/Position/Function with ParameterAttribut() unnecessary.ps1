Function TestParameterSet{
  Param (
    [Parameter()]
   [Switch] $A,
   
    [Parameter(Mandatory)]
   [Switch] $B,
   
    [Parameter(Position=1)]
   [Switch] $C,
   
    $D
   )
  Write-Host "Traitement..."
}