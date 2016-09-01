#Transformation de code : 

function TestScriptFileInfo
{
  if($commentLines.Count -gt 2)
  {
      for($i = 1; $i -lt ($commentLines.count - 1); $i++)
      {
          $line = $commentLines[$i]
      }
  }
}