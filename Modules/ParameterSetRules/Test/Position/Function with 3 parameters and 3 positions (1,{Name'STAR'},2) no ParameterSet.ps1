Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
    [Parameter()]
   [string] ${Name*},
    [Parameter(Position=3)]
   [string] $C
   )
  Write-Host "Test"
}
