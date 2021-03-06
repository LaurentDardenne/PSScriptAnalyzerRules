# ProvideValidNameForParameter
**Severity Level: Error**

## Description
A the name of a parameter name is invalid

### Function :  ParameterSetRules\Measure-DetectingErrorsInParameterList
## How to Fix
Chanhe the name of the parameter. 
It must not have begun by numbers.
It must not contains a dot character.
It must not contains a operator token.
It must not have begun or endung by spaces.
It must not contains Powershell wildcard.
...

## Example
### Wrong：
```PowerShell
Function TestParameterSet{
  Param (
    [Parameter(Position=1)]
   [string] $A,

   [string] $7Name,

    [Parameter(Position=2)]
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
 
   [string] $Name,
    
    [Parameter(Position=2)]
   [string] $C
   )
  Write-Verbose "Test"
}
```
