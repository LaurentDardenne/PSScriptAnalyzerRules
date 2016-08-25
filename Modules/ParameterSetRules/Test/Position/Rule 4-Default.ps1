Function TestParameterSet{
   
  Param (
    [Parameter(Position=2)]
   [string] $A,
    [Parameter(Position=3)]
   [string] $B,
    [Parameter(Position=4)]
   [string] $C
   )
   Write-Host"ParameterSetName =$($PsCmdlet.ParameterSetName)"
}