# J'installe un nouveau poste (IC ou nouveau poste de dev)
# ou je met à jour le poste local déjà installé

#Install ou met à jour les prérequis
#Appveyor utilisera tjr la dernière version

Properties { 
 $PSGallery=@{
   Modules=@('Pester','PsScriptAnalyzer')
 }
 $MyGet=@{
                        #PSNuspec posséde une dépendance sur XMLObject
   Modules=@('Log4Posh','PSNuspec','MeasureLocalizedData','DTW.PS.FileSystem',
              #Publish-Script fonctionne avec Myget
              #Install-Script ne fonctionne pas avec Myget
              #Mais Install-Module installe le script %-)
             'Edit-String','Lock-File','Remove-Conditionnal','Test-BOMFile','Using-Culture')
              #Install scripts into "${env:ProgramFiles}\WindowsPowerShell\Scripts"

 }
}

Task default -Depends Install,Update

Task Install -Depends RegisterPSRepository -Precondition { $Mode -eq  'Install'}  {
  
  #Suppose : PowershellGet à jour     
   
   #On précise le repository car Pester est également sur Nuget 
  PowershellGet\Install-Module -Name $PSGallery.Modules -Repository PSGallery -Scope AllUsers -force -SkipPublisherCheck   
  PowershellGet\Install-Module -Name $MyGet.Modules -Repository OttoMatt -force -Scope AllUsers 

  Set-location $Env:Temp
  nuget install ReportUnit
  #&"$Env:Temp\ReportUnit.1.2.1\tools\ReportUnit.exe"
}

Task RegisterPSRepository {
 $MyGetPublishUri = 'https://www.myget.org/F/ottomatt/api/v2/package'
 $MyGetSourceUri = 'https://www.myget.org/F/ottomatt/api/v2'
 
 $DEV_MyGetPublishUri = 'https://www.myget.org/F/devottomatt/api/v2/package'
 $DEV_MyGetSourceUri = 'https://www.myget.org/F/devottomatt/api/v2'
 
 try{
  Get-PSRepository OttoMatt -EA Stop >$null   
 } catch {
   if ($_.CategoryInfo.Category -ne 'ObjectNotFound')
   { throw $_ }
   else
   { Register-PSRepository -Name OttoMatt -SourceLocation $MyGetSourceUri -PublishLocation $MyGetPublishUri -InstallationPolicy Trusted }
 }
    
 try{
  Get-PSRepository DevOttoMatt -EA Stop >$null   
 } catch {
   if ($_.CategoryInfo.Category -ne 'ObjectNotFound')
   { throw $_ }
   else
   { Register-PSRepository -Name DevOttoMatt -SourceLocation $DEV_MyGetSourceUri -PublishLocation $DEV_MyGetPublishUri -InstallationPolicy Trusted }
 }
}

Task Update -Precondition { $Mode -eq 'Update'}  {     
  $sbUpdate={
      $ModuleName=$_
      try {
        Write-host "Update $ModuleName"
        Update-module -name $ModuleName -Force
      }
      catch [Microsoft.PowerShell.Commands.WriteErrorException]{
        if ($_.FullyQualifiedErrorId -match ('^ModuleNotInstalledOnThisMachine'))
        {
          Write-host "`tInstall $ModuleName"
          install-module -Name $ModuleName -Repository $CurrentRepository -Scope AllUsers 
        }
        else 
        { throw $_ }
      }
  }     
  $CurrentRepository='PSGallery'
   $PSGallery.Modules|Foreach-Object $sbUpdate

  $CurrentRepository='OttoMatt'  
   $MyGet.Modules|Foreach-Object $sbUpdate  
}
