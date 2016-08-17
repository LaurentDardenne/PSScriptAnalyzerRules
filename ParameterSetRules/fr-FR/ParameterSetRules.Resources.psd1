ConvertFrom-StringData @'
# French strings
W_DpsNotDeclared={0} : L'attribut [CmdletBinding] ne déclare pas sa propriété 'DefaultParameterSetName'. 
I_PsnRedundant={0} : Les instructions de nom de jeux de paramètres sont redondantes, car il n'existe qu'un seul jeu.
W_DpsAvoid_AllParameterSets_Name={0} : Evitez d'utiliser '__AllParameterSets' pour un nom de jeu de paramètres.
I_DpsUnnecessary={0} : La déclaration unique du nom de jeu de paramètre par défaut est inutile (cf. attribut [CmdletBinding]).
E_DpsInused={0} : Le nom du jeu de paramètre par défaut ne référence aucun des noms de jeu de paramètres existant.
E_CheckPsnCaseSensitive={0} : Les nom de jeux de paramètres sont sensibles à la casse, un conflit a été détecté : {1}
Correction_CheckPsnCaseSensitive={0} : Contrôlez la casse des noms de jeux de paramètres concernés.
'@