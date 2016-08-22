Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
    [Parameter(Position=2)]
   [string] $B,
    [Parameter(Position=4)]
   [string] $C
   )
  Write-Output "Test"
}
