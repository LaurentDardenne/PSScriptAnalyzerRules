Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "Name2")]
  Param (
   [Parameter(ParameterSetName="Name1")]
   [Switch] $A,

   [Parameter(ParameterSetName="Name2")]
   [Switch] $B
  )
  Write-Host "Traitement..."
}
