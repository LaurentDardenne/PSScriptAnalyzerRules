﻿Function TestParameterSet{
 [CmdletBinding(DefaultParameterSetName = "Name2")]
  Param (
    [Parameter(ParameterSetName="Name1")]
    [Switch] $A
  )
  Write-Host "Traitement..."
}

