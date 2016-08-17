Function TestParameterSet{
 [CmdletBinding(DefaultParameterSetName = "inused")]
  Param (
   [Switch] $A,
   [Switch] $B
   )
  Write-Host "Traitement..."
}
