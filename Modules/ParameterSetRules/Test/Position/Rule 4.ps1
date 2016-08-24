Function TestParameterSet{
 [CmdletBinding(DefaultParameterSetName='F2')]       
  Param (
    [Parameter(Position=2,ParametersetName="F2")]
   [string] $A,
    [Parameter(Position=3,ParametersetName="F2")]
   [string] $B,
    [Parameter(Position=4,ParametersetName="F3")]
   [string] $C
   )
   Write-Host"ParameterSetName =$($PsCmdlet.ParameterSetName)"
}