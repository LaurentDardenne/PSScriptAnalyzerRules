Function TestParamName{
[cmdletbinding()]
 param(
    [int] $first,
    #[string] ${first}, #error DuplicateFormalParameter
    [Switch] $32Bit,
    $64bits,
    $1certain,
    #$.0  #parsing erreur    MissingExpressionAfterToken
    ${.0},
    #$-1, #parsing erreur
    ${-1},
    #+2, #parsing erreur
    ${+2},
    #*3, #parsing erreur
    ${*3}, #                 
    #/4, #parsing erreur
    ${/4},
    ${ AvantDernier},
    #$' Dernier' #parsing erreur
    $$,
    $^,
    $?,
    #Der[nier, #erreur 'MissingEndParenthesisInFunctionParameterList'
    ${Der[nier},
    ${global:Test} # Scope
  )#param
 
 Write-Host 'suite'    
 $psboundparameters         
}

