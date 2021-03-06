# AvoidUsingUnnecessaryParameterAttribut
**Severity Level: Warning**

## Description
A parameter declare an unnecessary ParameterAttribut.

### Function :  ParameterSetRules\Measure-DetectingErrorsInParameterList

## How to Fix
Remove the ParameterAttribut or complete it.

## Example
### Wrong：
```PowerShell
Function TestParameterSet{
  Param (
    [Parameter()]
   [Switch] $A,
   
    [Parameter(Mandatory)]
   [Switch] $B,
   
    [Parameter(Position=1)]
   [Switch] $C,
   
    $D
   )
 Write-Verbose "Processing..."
}
```

### Correct:
```PowerShell
Function TestParameterSet{
  Param (
   [Switch] $A,
   
    [Parameter(Mandatory)]
   [Switch] $B,
   
    [Parameter(Position=1)]
   [Switch] $C,
   
    $D
   )
 Write-Verbose "Processing..."
}
```
