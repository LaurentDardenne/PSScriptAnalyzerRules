
Function ValideParameterSet4{
  Param (
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A
    )
  Write-Host "Traitement..."
}

Function ValideParameterSet6{
 [CmdletBinding(DefaultParameterSetName="Toto")]         
  Param( 
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A
  )
}  

Function ValideParameterSet61{
 [CmdletBinding(DefaultParameterSetName="Fonctionnalite1")]         
  Param( 
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A
  )
}  

Function ValideParameterSet62{
 [CmdletBinding(DefaultParameterSetName="fonctionnalite1")]         
  Param( 
    [Parameter(ParameterSetName="Fonctionnalite1")]
   [Switch] $A
  )
}  