ConvertFrom-StringData @'
# French strings
   # Measure-DetectingErrorsInDefaultParameterSetName
W_DpsNotDeclared={0} : L'attribut [CmdletBinding] ne déclare pas sa propriété 'DefaultParameterSetName'. 
I_PsnRedundant={0} : Les instructions de nom de jeux de paramètres sont redondantes, car il n'existe qu'un seul jeu.
W_DpsAvoid_AllParameterSets_Name={0} : Evitez d'utiliser '__AllParameterSets' pour un nom de jeu de paramètres.
I_DpsUnnecessary={0} : La déclaration unique du nom de jeu de paramètre par défaut est inutile (cf. attribut [CmdletBinding]).
E_DpsInused={0} : Le nom du jeu de paramètre par défaut ne référence aucun des noms de jeu de paramètres existant.
E_CheckPsnCaseSensitive={0} : Les nom de jeux de paramètres sont sensibles à la casse, un conflit a été détecté : {1}
Correction_CheckPsnCaseSensitive={0} : Contrôlez la casse des noms de jeux de paramètres concernés.

  # Measure-DetectingErrorsInParameterList
W_PsnUnnecessaryParameterAttribut={0} : Le paramètre '{1}' déclare un attribut [Parameter()] inutile.
W_PsnParametersMustBeginByZeroOrOne={0} : '{1}' la position des paramètres doit débuter par zéro ou un : {2}
E_PsnPositionsAreNotSequential={0} : Le jeu de paramètres '{1}' contient des nombres de positions qui ne forment pas une suite ordonnées : {2}
E_PsnMustHavePositivePosition={0} : Dans le jeu de paramètres '{1}', le paramètre '{2}' doit avoir un position positive ({3})
E_PsnDuplicatePosition={0} : Le jeu de paramètres '{1}' contient une ou des positions dupliquées {2} pour les paramètres {3}

E_ParameterNameContainsInvalidCharacter={0} : Le nom du paramètre '{1}' est invalide :
E_ParameterNameInvalidByNumber=Il ne doit pas débuter par un ou des chiffres.
E_ParameterNameInvalidByDot=Il ne doit pas contenir le caractère point ('.').
E_ParameterNameInvalidByOperator=Il ne doit pas contenir un symbole d'opérateur Powershell.
E_ParameterNameInvalidBySpace=Il ne doit pas débuter ou se terminer par des espaces.
E_ParameterNameInvalidByPSWildcard=Il ne doit pas contenir des jokers Powershell ('*', '?', '[', ']').
'@