Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "name1")]
  Param (
   [Parameter(ParameterSetName="Name1")]
   [Switch] $A,
   
   [Parameter(ParameterSetName="Name1")]
   [Switch] $B
  )
  Write-Host "Traitement..."
}
