Function TestParameterSet{
  [CmdletBinding()]
  Param (
    [Parameter(ParameterSetName="Name1")]
   [Switch] $A,
    [Parameter(ParameterSetName="name1")]
   [Switch] $B
   )
  
  Write-Host "Traitement..."
}