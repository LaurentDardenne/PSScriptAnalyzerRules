# ProvideParameterWithPositivePosition
**Severity Level: Error**

## Description
In a ParameterSet all parameter position must have a positive position

### Function :  ParameterSetRules\Measure-DetectingErrorsInParameterList
## How to Fix
Change the negative position number

## Example
### Wrong：
```PowerShell
Function TestParameterSet{
  Param (
    [Parameter(Position=-1)]
   [string] $A,
    [Parameter(Position=0)]
   [string] $B,
    [Parameter(Position=1)]
   [string] $C
   )
  Write-Verbose "Test"
}
```
### Correct:
```PowerShell
Function TestParameterSet{
  Param (
    [Parameter(Position=0)]
   [string] $A,
    [Parameter(Position=1)]
   [string] $B,
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Verbose "Test"
}
```
