# ProvideDefaultParameterSetName
**Severity Level: Warning**

## Description
DefaultParameterSetName is not declared.

### Function :  ParameterSetRules\Measure-DetectingErrorsInDefaultParameterSetName

## How to Fix

## Example
### Wrong：
```PowerShell
Function TestParameterSet{
 [CmdletBinding()]
  Param (
    [Parameter(ParameterSetName="Name1")]
    [Switch] $A,
   
    [Parameter(ParameterSetName="Name2")]
    [Switch] $B
   )
 Write-Verbose "Processing..."
}

```
### Correct:
```PowerShell
Function TestParameterSet{
  [CmdletBinding(DefaultParameterSetName = "Name1")]
  Param (
    [Parameter(ParameterSetName="Name1")]
    [Switch] $A,
   
    [Parameter(ParameterSetName="Name2")]
    [Switch] $B
   )
 Write-Verbose "Processing..."
}

```
