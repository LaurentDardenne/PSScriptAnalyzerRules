param()
if($commentLines.Count -gt 2)
{
    $Count=$commentLines.count - 1
    for($i = 1; $i -lt $Count; $i++)
    {
        $line = $commentLines[$i]
    }
}

function TestScriptFileInfo
{
  if($commentLines.Count -gt 2)
  {
      $Count=$commentLines.count - 1
      for($i = 1; $i -lt $count; $i++)
      {
          $line = $commentLines[$i]
      }
  }

}