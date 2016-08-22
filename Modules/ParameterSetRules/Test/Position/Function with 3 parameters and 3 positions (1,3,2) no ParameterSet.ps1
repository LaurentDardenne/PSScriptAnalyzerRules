Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
    [Parameter(Position=3)]
   [string] $B,
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Host "Test"
}
