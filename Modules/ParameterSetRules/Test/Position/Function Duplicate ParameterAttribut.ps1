Function TestParameterSet{
  [CmdletBinding(defaultparameterSetName = "F3")]
  [CmdletBinding(defaultparameterSetName = "F3")]  
  
  Param ( 
    [Parameter(Position=1)]
    [Parameter(Position=1,ParametersetName="F2")]
   [Switch] $A,

    [Parameter(Position=2,ParameterSetname="F2")]
    [Parameter(Position=2,ParameterSetname="F2")]
   [Switch] $B,

    [Parameter(Position=0)]
    [Parameter(Position=0,parameterSetName="F3")]
    [Parameter(Position=1)]
   [Switch] $C,
   
    [Parameter(ParameterSetname="F2")]
    [Parameter(Position=2,ParameterSetname="F2")]
   [Switch] $D   
  )
  Write-Host "Traitement..."
}