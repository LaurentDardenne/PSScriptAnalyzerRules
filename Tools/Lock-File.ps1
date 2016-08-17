Function Lock-File{
#Verrouille un fichier à des fins de tests
  param([string] $Path)

  New-Object System.IO.FileStream($Path, 
                                  [System.IO.FileMode]::Open, 
                                  [System.IO.FileAccess]::ReadWrite, 
                                  [System.IO.FileShare]::None)
} #Lock-File

return

&{
 try {
    $Filename="C:\Temp\t1.txt"
    $TestLockFile= Lock-File $FileName
    Test-IncludeFile $PsionicIncludeFiles
  } finally {
   $TestLockFile.Close()
  }
}
