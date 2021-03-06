# AvoidDuplicateParameterPosition
**Severity Level: Error**

## Description
A ParameterSet contains duplicate position for parameters

### Function :  ParameterSetRules\Measure-DetectingErrorsInParameterList
## How to Fix
Change the numbering of the position

## Example
### Wrong：
```PowerShell
Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,
    [Parameter(Position=2)]
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
    [Parameter(Position=1)]
   [string] $A,
    [Parameter(Position=2)]
   [string] $B,
    [Parameter(Position=3)]
   [string] $C
   )
  Write-Verbose "Test"
}
```
