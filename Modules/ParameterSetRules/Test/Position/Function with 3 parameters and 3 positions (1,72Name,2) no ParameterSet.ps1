Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
    [Parameter()]
   [string] $72Name,
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Host "Test"
}
