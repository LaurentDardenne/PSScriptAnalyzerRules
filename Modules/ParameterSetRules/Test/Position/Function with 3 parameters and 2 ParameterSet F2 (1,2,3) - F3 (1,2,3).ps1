Function TestParameterSet{
  Param (
    [Parameter(Position=1,ParametersetName="F2")]
   [string] $A,
    [Parameter(Position=2,ParametersetName="F2")]
   [string] $B,
    [Parameter(Position=3,ParametersetName="F2")]
   [string] $C,
   
    [Parameter(Position=1,ParametersetName="F3")]
   [string] $D,
    [Parameter(Position=2,ParametersetName="F3")]
   [string] $E,
    [Parameter(Position=3,ParametersetName="F3")]
   [string] $F   
   )
   Write-Host "ParameterSetName =$($PsCmdlet.ParameterSetName)"
}