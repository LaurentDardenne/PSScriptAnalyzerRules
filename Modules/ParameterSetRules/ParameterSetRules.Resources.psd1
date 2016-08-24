ConvertFrom-StringData @'
# English strings
  # Measure-DetectingErrorsInDefaultParameterSetName
W_DpsNotDeclared={0} : DefaultParameterSetName is not declared. 
I_PsnRedundant={0} : The statement of parameter set name is redundant because one single parameter set name was found.
W_DpsAvoid_AllParameterSets_Name={0} : Avoid to use '__AllParameterSets' as name of a parameter set.
I_DpsUnnecessary={0} : The single declaration of default parameter set name is unnecessary (see attribute [CmdletBinding]).
E_DpsInused={0} : The default parameter set name does not refer to a existing parameter set name.  
E_CheckPsnCaseSensitive={0} : The parameter set names are case sensitive, conflicts were detected : {1}
Correction_CheckPsnCaseSensitive={0} : Check the character case of the parameter set names.

  # Measure-DetectingErrorsInParameterList
W_PsnUnnecessaryParameterAttribut={0} : The parameter '{1}' declare an unnecessary ParameterAttribut.
E_PsnParametersMustBeginByZeroOrOne={0} : '{1}' The positions of parameters must begin by zero or one: {2}
E_PsnPositionsAreNotSequential={0} : The ParameterSet '{1}' contains positions which are not sequential: {2}
E_PsnMustHavePositivePosition={0} : In the ParameterSet '{1}', the parameter '{2}' must have a positive position ({3})
E_PsnDuplicatePosition={0} : The ParameterSet '{1}' contains duplicate position {2} for the parameters {3}
 
E_ParameterNameContainsInvalidCharacter={0} : The parameter name '{1}' is invalid :
E_ParameterNameInvalidByNumber=it must not have begun by numbers.
E_ParameterNameInvalidByDot=it must not contains a dot character.
E_ParameterNameInvalidByOperator=it must not contains a operator token.
E_ParameterNameInvalidBySpace=it must not have begun or endung by spaces.
E_ParameterNameInvalidByPSWildcard=it must not contains Powershell wildcard.

'@