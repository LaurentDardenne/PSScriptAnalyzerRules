Function TestParameterSet{
  Param (
    [Parameter(Position=-1)]
   [string] $A,
    [Parameter(Position=0)]
   [string] $B,
    [Parameter(Position=1)]
   [string] $C
   )
  Write-Host "Test"
}
