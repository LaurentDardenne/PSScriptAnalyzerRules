Function TestParameterSet{
  [CmdletBinding(defaultparameterSetName = "F3")]
  [CmdletBinding(defaultparameterSetName = "F3")]  
  
  Param ( 
    [Parameter(Position=3,ParametersetName="F2")]
   [Switch] $A,
    [Parameter(Position=2,ParameterSetname="F2")]
   [Switch] $B,
    [Parameter(Position=0,parameterSetName="F3")]
   [Switch] $C,
   
    [Parameter(Position=1,ParameterSetName="F2")]
    [Parameter(Position=2,ParameterSetName="F3")]
   [Switch] $D,
    [Parameter(Position=1,ParameterSetName="F3")]
   [Switch] $E,

   [Switch] $F,
    
    [Parameter(Position=3)]
   [Int] $G=10,
   
    [Parameter(ParameterSetName="F4")]
   [Switch] $H,
    [Parameter(ParameterSetName="F4")]
   [Switch] $I,
    [Parameter(ParameterSetName="F4")]
    $J,

    [Parameter(Position=1,ParameterSetName="F5")]
   [Switch] $k,
    [Parameter(Position=2,ParameterSetName="F5")]
   [Switch] $l,
    [Parameter(Position=1,ParameterSetName="F5")]
    $m ,
    
    [Parameter(Position=5,ParameterSetName="F6")]
   [Switch] $n,
    [Parameter(Position=4,ParameterSetName="F6")]
   [Switch] $o,
    [Parameter(Position=3,ParameterSetName="F6")]
    $p,
    
    [Parameter(Position=1)]
    [Parameter(ParameterSetName="F6")]
    $q,
    
    [Parameter(Position=-3,ParameterSetName="F7")]
    ${32Bits},
    
    [Parameter()]
    ${S}
   )
}