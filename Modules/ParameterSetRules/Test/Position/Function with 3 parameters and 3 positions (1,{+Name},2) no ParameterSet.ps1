Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
   [string] ${+Name},
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Host "Test"
}
