Function TestParameterSet{
  Param (
    [Parameter(Position=1,ParametersetName="F2")]
   [string] $A,
    [Parameter(Position=2,ParametersetName="F2")]
   [string] $B,
    [Parameter(Position=3,ParametersetName="F3")]
   [string] $C
   )
   Write-Host"ParameterSetName =$($PsCmdlet.ParameterSetName)"
}