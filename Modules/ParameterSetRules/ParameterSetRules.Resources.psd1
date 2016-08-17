ConvertFrom-StringData @'
# English strings
W_DpsNotDeclared={0} : DefaultParameterSetName is not declared. 
I_PsnRedundant={0} : The statement of parameter set name is redundant because one single parameter set name was found.
W_DpsAvoid_AllParameterSets_Name={0} : Avoid to use '__AllParameterSets' as name of a parameter set.
I_DpsUnnecessary={0} : The single declaration of default parameter set name is unnecessary (see attribute [CmdletBinding]).
E_DpsInused={0} : The default parameter set name does not refer to a existing parameter set name.  
E_CheckPsnCaseSensitive={0} : The parameter set names are case sensitive, conflicts were detected : {1}
Correction_CheckPsnCaseSensitive={0} : Check the character case of the parameter set names.
'@