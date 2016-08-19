Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "Name1")]
  Param (
    [Switch] $A
  )
  
  Write-Host "Traitement..."
}
