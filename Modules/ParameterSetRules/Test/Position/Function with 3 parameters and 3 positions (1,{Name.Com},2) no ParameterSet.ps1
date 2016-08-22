Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
   [string] ${Name.Com},
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Host "Test"
}
